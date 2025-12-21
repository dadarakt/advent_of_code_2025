import gleam/int
import gleam/io

import gleam/list
import gleam/order.{type Order}
import gleam/result
import inputs
import point_3d.{type Point3D}

import gleam/float

pub type Circuit {
  Circuit(junction_boxes: List(Point3D))
}

fn circuit_distance(a: Circuit, b: Circuit) -> Result(Float, Nil) {
  case a.junction_boxes |> list.is_empty || b.junction_boxes |> list.is_empty {
    True -> Error(Nil)
    False -> {
      let assert Ok(first_a) = list.first(a.junction_boxes)
      let assert Ok(first_b) = list.first(b.junction_boxes)
      let start_min = point_3d.distance(first_a, first_b)
      Ok(circuit_distance_loop(a.junction_boxes, b.junction_boxes, start_min))
    }
  }
}

fn circuit_distance_loop(points_a, points_b, min) {
  case points_a {
    [] -> min
    [first, ..rest] -> {
      let assert Ok(local_min) =
        points_b
        |> list.map(fn(b) { point_3d.distance(first, b) })
        |> min_of_list(float.compare)

      case float.compare(local_min, min) {
        order.Lt -> circuit_distance_loop(rest, points_b, local_min)
        order.Eq | order.Gt -> circuit_distance_loop(rest, points_b, min)
      }
    }
  }
}

pub fn main() {
  let circuits: List(Circuit) = inputs.input_for_day(8, parse_circuits)

  let merged =
    connect_closest_circuits(circuits, 1000, 0.0)
    |> list.map(fn(c) { c.junction_boxes |> list.length })
    |> list.sort(int.compare)

  let top_3_product =
    merged
    |> list.drop(list.length(merged) - 3)
    |> list.fold(1, fn(acc, i) { acc * i })

  io.println(
    "The three biggest circuit's sizes multiplied are "
    <> top_3_product |> int.to_string,
  )

  echo merged
}

const unreasonable_number = 1_000_000_000_000.0

pub fn find_closest_junction_boxes(
  circuits: List(Circuit),
  min_distance: Float,
) -> Result(#(#(Circuit, Circuit), Float), Nil) {
  case circuits {
    [] -> Error(Nil)
    [c] -> Ok(#(#(c, c), min_distance))
    circuits -> {
      let assert Ok(#(#(p_a, c_a), #(p_b, c_b))) =
        list.flat_map(circuits, fn(c) {
          c.junction_boxes
          |> list.map(fn(b) { #(b, c) })
        })
        |> list.combination_pairs()
        |> min_of_list(fn(a, b) {
          let #(#(a1, _), #(a2, _)) = a
          let #(#(b1, _), #(b2, _)) = b

          let dist_a = point_3d.distance(a1, a2)
          let dist_a = case dist_a >. min_distance {
            True -> dist_a
            False -> unreasonable_number
          }
          let dist_b = point_3d.distance(b1, b2)
          let dist_b = case dist_b >. min_distance {
            True -> dist_b
            False -> unreasonable_number
          }

          float.compare(dist_a, dist_b)
        })

      Ok(#(#(c_a, c_b), point_3d.distance(p_a, p_b)))
    }
  }
}

pub fn connect_closest_circuits(
  circuits: List(Circuit),
  n: Int,
  min_dist: Float,
) -> List(Circuit) {
  case n {
    0 -> circuits
    n -> {
      case circuits {
        [] -> []
        [_circuit] as circuits -> circuits
        circuits -> {
          let assert Ok(#(#(min_a, min_b), new_min_dist)) =
            find_closest_junction_boxes(circuits, min_dist)

          let merged_circuit = merge_circuits(min_a, min_b)

          let updated_circuits =
            circuits
            |> list.filter(fn(c) { c != min_a && c != min_b })
            |> list.prepend(merged_circuit)

          connect_closest_circuits(updated_circuits, n - 1, new_min_dist)
        }
      }
    }
  }
}

pub fn merge_circuits(a: Circuit, b: Circuit) -> Circuit {
  case a == b {
    True -> a
    False -> Circuit(list.append(a.junction_boxes, b.junction_boxes))
  }
}

pub fn parse_circuits(str: String) -> List(Circuit) {
  point_3d.points_from_string(str)
  |> list.map(fn(p) { Circuit([p]) })
}

pub fn find_closest_circuits(
  circuits: List(Circuit),
) -> Result(#(Circuit, Circuit), Nil) {
  circuits
  |> list.combination_pairs()
  |> list.flat_map(fn(t) {
    let #(a, b) = t
    case circuit_distance(a, b) {
      Ok(dist) -> [#(dist, t)]
      Error(Nil) -> []
    }
  })
  |> min_of_list(fn(a, b) {
    let #(dist_a, _) = a
    let #(dist_b, _) = b
    float.compare(dist_a, dist_b)
  })
  |> result.map(fn(t) {
    let #(_, circuits) = t
    circuits
  })
}

pub fn minimal_pairwise_distance(points: List(Point3D)) -> #(Point3D, Point3D) {
  let assert Ok(min_pair) =
    points
    |> list.combination_pairs()
    |> min_of_list(fn(a, b) {
      let #(a_1, a_2) = a
      let #(b_1, b_2) = b

      float.compare(point_3d.distance(a_1, a_2), point_3d.distance(b_1, b_2))
    })
  min_pair
}

pub fn min_of_list(
  over list: List(a),
  with order: fn(a, a) -> Order,
) -> Result(a, Nil) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] -> Ok(min_of_list_loop(rest, order, first))
  }
}

fn min_of_list_loop(list, order, min) {
  case list {
    [] -> min
    [first, ..rest] -> {
      case order(first, min) {
        order.Gt | order.Eq -> min_of_list_loop(rest, order, min)
        order.Lt -> min_of_list_loop(rest, order, first)
      }
    }
  }
}
