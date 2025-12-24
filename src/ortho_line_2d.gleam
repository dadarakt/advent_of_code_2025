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

pub type Vec2D {
  Vec2D(x: Int, y: Int)
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

fn cross_product(a: Vec2D, b: Vec2D) -> Int {
  a.x * b.y - b.x * a.y
}

pub type Orientation {
  Clockwise
  AntiClockwise
  Zero
}

fn orientation(p: Point2D, l: OrthoLine2D) -> Orientation {
  let cross_product =
    { l.from.x - p.x }
    * { l.to.y - p.y }
    - { l.to.x - p.x }
    * { l.from.y - p.y }

  case cross_product {
    x if x > 0 -> Clockwise
    x if x < 0 -> AntiClockwise
    _ -> Zero
  }
}

pub fn crossing(a: OrthoLine2D, b: OrthoLine2D) -> Bool {
  let o1 = orientation(b.from, a)
  let o2 = orientation(b.to, a)
  let o3 = orientation(a.from, b)
  let o4 = orientation(a.to, b)

  case { Zero == o1 && Zero == o2 } || { Zero == o3 && Zero == o4 } {
    True -> {
      // colinear
      {
        { b.from.x >= a.from.x && b.from.x <= a.to.x }
        && { b.from.y >= a.from.y && b.from.y <= a.to.y }
      }
      || {
        { b.to.x >= a.from.x && b.to.x <= a.to.x }
        && { b.to.y >= a.from.y && b.to.y <= a.to.y }
      }
    }
    False -> o1 != o2 && o3 != o4
  }
}

pub fn do_cross(a: OrthoLine2D, b: OrthoLine2D) -> Bool {
  case dir(a), dir(b) {
    Horizontal, Horizontal -> {
      case a.from.x == b.from.x {
        True -> overlap(a.from.x, a.to.x, b.from.x, b.to.x)
        False -> False
      }
    }
    Vertical, Vertical -> {
      case a.from.y == b.from.y {
        True -> overlap(a.from.y, a.to.y, b.from.y, b.to.y)
        False -> False
      }
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
