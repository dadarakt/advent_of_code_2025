import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
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
