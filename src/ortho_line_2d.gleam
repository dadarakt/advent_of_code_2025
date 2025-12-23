import gleam/int
import point_2d.{type Point2D}

// 2 dimensional line-segment that is either vertical / horizontal
pub opaque type OrthoLine2D {
  OrthoLine2D(from: Point2D, to: Point2D)
}

pub type Dir {
  Vertical
  Horizontal
}

pub fn new(from: Point2D, to: Point2D) -> Result(OrthoLine2D, Nil) {
  let orthogonal = from.x == to.x || from.y == to.y
  let length_pos =
    int.absolute_value(to.x - from.x) + int.absolute_value(to.y - from.y) > 0

  case orthogonal && length_pos {
    True -> Ok(OrthoLine2D(from, to))
    False -> Error(Nil)
  }
}

pub fn dir(line: OrthoLine2D) -> Dir {
  case line.from.x == line.to.x {
    True -> Vertical
    False -> Horizontal
  }
}

pub fn do_cross(a: OrthoLine2D, b: OrthoLine2D) -> Bool {
  case dir(a), dir(b) {
    Horizontal, Horizontal -> {
      overlap(a.from.x, a.to.x, b.from.x, b.to.x)
    }
    Vertical, Vertical -> {
      overlap(a.from.y, a.to.y, b.from.y, b.to.y)
    }
    _, _ -> {
      // TODO
      False
    }
  }
}

fn overlap(a_from, a_to, b_from, b_to) {
  a_to + 1 < b_from || b_to + 1 < a_from
}
