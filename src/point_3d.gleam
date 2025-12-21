import gleam/int
import gleam/list
import gleam/string

pub type Point3D {
  Point3D(x: Int, y: Int, z: Int)
}

pub fn points_from_string(str: String) -> List(Point3D) {
  string.split(str, "\n")
  |> list.filter(fn(l) { l != "" })
  |> list.map(from_string)
}

fn from_string(str: String) -> Point3D {
  let assert [x, y, z] =
    string.split(str, ",")
    |> list.map(fn(split) {
      let assert Ok(int) = int.parse(string.trim(split))
      int
    })

  Point3D(x, y, z)
}

pub fn distance(a: Point3D, b: Point3D) -> Float {
  let sum_of_squared_diffs =
    { { a.x - b.x } * { a.x - b.x } }
    + { { a.y - b.y } * { a.y - b.y } }
    + { { a.z - b.z } * { a.z - b.z } }

  // cannot be negative due to squaring before
  let assert Ok(root) = int.square_root(sum_of_squared_diffs)
  root
}
