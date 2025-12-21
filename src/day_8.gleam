import gleam/list
import gleam/order.{type Order}
import gleam/result
import inputs
import point_3d.{type Point3D}

import gleam/float

pub type Circuit {
  Circuit(junction_boxes: List(Point3D))
}

fn circuit_distance(circuits: #(Circuit, Circuit)) -> Result(Float, Nil) {
  let #(a, b) = circuits
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
  let initial_circuits: List(Circuit) = inputs.input_for_day(8, parse_circuits)

  let assert Ok(#(min_circuit_a, min_circuit_b)) =
    find_closest_circuits(initial_circuits)

  echo min_circuit_a
  echo min_circuit_b
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
    case circuit_distance(t) {
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
