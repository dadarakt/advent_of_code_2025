import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/set.{type Set}
import gleam/string

import inputs

pub type Rectangle {
  // assumes opposite corners
  Rectangle(a: Point2D, b: Point2D)
}

pub fn main() {
  let points = inputs.input_for_day(9, points_from_string)
  let max_area = maximal_rectangle(points)

  io.println("The maximal area is " <> int.to_string(max_area))

  print_tiles(points)
}

pub fn area(r: Rectangle) -> Int {
  { r.b.x - r.a.x } * { r.b.y - r.a.y }
}

pub fn rectangle_area(a: Point2D, b: Point2D) -> Int {
  let diff_x = int.absolute_value(a.x - b.x) + 1
  let diff_y = int.absolute_value(a.y - b.y) + 1

  diff_x * diff_y
}

pub type Point2D {
  Point2D(x: Int, y: Int)
}

pub type Line2D {
  Line2D(from: Point2D, to: Point2D)
}

pub type Polygon2D {
  Polygon2D(lines: List(Line2D))
}

/// assumes that points loop
pub fn polygon_from_points(points: List(Point2D)) -> Polygon2D {
  case points {
    [] | [_] -> Polygon2D([])
    [first, _, ..] -> {
      Polygon2D(lines_from_points_loop(points, first))
    }
  }
}

fn lines_from_points_loop(points, first) {
  case points {
    [] -> []
    [last] -> [Line2D(last, first)]
    [first, second, ..rest] -> [
      Line2D(first, second),
      ..lines_from_points_loop([second, ..rest], first)
    ]
  }
}

pub fn maximal_rectangle(points: List(Point2D)) {
  let points_dict =
    points
    |> list.index_map(fn(p, idx) { #(idx, p) })
    |> dict.from_list()

  max_rectangle_loop(points_dict, list.length(points), 0, 0, 0)
}

fn max_rectangle_loop(points_dict, num_points, idx_a, idx_b, max) {
  case idx_a >= num_points {
    True -> max
    False -> {
      case idx_b >= num_points {
        True -> max_rectangle_loop(points_dict, num_points, idx_a + 1, 0, max)
        False -> {
          let assert Ok(a) = dict.get(points_dict, idx_a)
          let assert Ok(b) = dict.get(points_dict, idx_b)
          let area = rectangle_area(a, b)

          case int.compare(area, max) {
            order.Gt ->
              max_rectangle_loop(
                points_dict,
                num_points,
                idx_a,
                idx_b + 1,
                area,
              )
            order.Lt | order.Eq ->
              max_rectangle_loop(points_dict, num_points, idx_a, idx_b + 1, max)
          }
        }
      }
    }
  }
}

pub fn print_tiles(points: List(Point2D)) {
  let assert Ok(#(min_x, max_x)) =
    min_max_by(points, fn(a, b) { int.compare(a.x, b.x) })
  let assert Ok(#(min_y, max_y)) =
    min_max_by(points, fn(a, b) { int.compare(a.y, b.y) })

  let points_set: Set(#(Int, Int)) =
    points
    |> list.map(fn(p) { #(p.x, p.y) })
    |> set.from_list()

  io.println("")
  print_tiles_loop(points_set, min_x.x, max_x.x, max_y.y, min_x.x, min_y.y)
}

fn print_tiles_loop(points_set, min_x, max_x, max_y, idx_x, idx_y) {
  case idx_y > max_y {
    True -> io.println("")
    False -> {
      case idx_x > max_x {
        True -> {
          io.println("")
          print_tiles_loop(points_set, min_x, max_x, max_y, min_x, idx_y + 1)
        }
        False -> {
          case set.contains(points_set, #(idx_x, idx_y)) {
            True -> io.print("#")
            False -> io.print(".")
          }
          print_tiles_loop(points_set, min_x, max_x, max_y, idx_x + 1, idx_y)
        }
      }
    }
  }
}

pub fn min_max_by(l: List(a), order: fn(a, a) -> Order) -> Result(#(a, a), Nil) {
  case l {
    [] -> Error(Nil)
    [first, ..rest] -> {
      min_max_loop(rest, order, first, first)
    }
  }
}

fn min_max_loop(l, order, min, max) {
  case l {
    [] -> Ok(#(min, max))
    [first, ..rest] -> {
      let new_min = case order(first, min) {
        order.Lt -> first
        order.Gt | order.Eq -> min
      }

      let new_max = case order(first, max) {
        order.Gt -> first
        order.Lt | order.Eq -> max
      }

      min_max_loop(rest, order, new_min, new_max)
    }
  }
}

fn all_reactangles_from_points_loop(points, rectangles) {
  case points {
    [] -> rectangles
    [first, ..rest] -> {
      todo
    }
  }
}

pub fn points_from_string(str: String) -> List(Point2D) {
  string.split(str, "\n")
  |> list.filter(fn(l) { l != "" })
  |> list.map(from_string)
}

pub fn from_string(str: String) -> Point2D {
  let assert [x, y] =
    string.split(str, ",")
    |> list.map(fn(split) {
      let assert Ok(int) = int.parse(string.trim(split))
      int
    })

  Point2D(x, y)
}
