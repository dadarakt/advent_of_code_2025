import gleam/int
import gleam/list
import gleam/string

pub type Rectangle {
  // assumes opposite corners
  Rectangle(a: Point2D, b: Point2D)
}

pub fn area(r: Rectangle) -> Int {
  { r.b.x - r.a.x } * { r.b.y - r.a.y }
}

pub type Point2D {
  Point2D(x: Int, y: Int)
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
