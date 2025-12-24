import gleam/int
import ortho_line_2d
import point_2d

pub fn constructor_test() {
  assert Error(Nil)
    == ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(0, 0))

  assert Error(Nil)
    == ortho_line_2d.new(point_2d.Point2D(0, 1), point_2d.Point2D(1, 0))

  let assert Ok(line) =
    ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(0, 10))
  assert ortho_line_2d.Vertical == ortho_line_2d.dir(line)

  let assert Ok(line) =
    ortho_line_2d.new(point_2d.Point2D(10, 10), point_2d.Point2D(5, 10))
  assert ortho_line_2d.Horizontal == ortho_line_2d.dir(line)
}

pub fn crossing_test() {
  // parallel lines horizontal
  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 10), point_2d.Point2D(0, 20))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(1, 10), point_2d.Point2D(1, 20))
  assert False == ortho_line_2d.crossing(a, b)

  // parallel lines vertical
  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 10), point_2d.Point2D(10, 10))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(0, 11), point_2d.Point2D(0, 21))
  assert False == ortho_line_2d.crossing(a, b)

  // non-overlapping colinear
  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(10, 0))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(15, 0), point_2d.Point2D(20, 0))
  assert False == ortho_line_2d.crossing(a, b)

  // overlapping colinear
  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(10, 0))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(10, 0), point_2d.Point2D(20, 0))
  assert True == ortho_line_2d.crossing(a, b)

  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(10, 0))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(5, 0), point_2d.Point2D(15, 0))
  assert True == ortho_line_2d.crossing(a, b)

  // crossing lines
  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(0, 10))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(-5, 5), point_2d.Point2D(10, 5))
  assert True == ortho_line_2d.crossing(a, b)

  // t lines
  let assert Ok(a) =
    ortho_line_2d.new(point_2d.Point2D(0, 0), point_2d.Point2D(0, 10))
  let assert Ok(b) =
    ortho_line_2d.new(point_2d.Point2D(0, 5), point_2d.Point2D(10, 5))
  assert True == ortho_line_2d.crossing(a, b)
}

pub fn xor_swap_test() {
  let x = 42
  let y = 420

  let x = int.bitwise_exclusive_or(y, x)
  // x: y^x
  let y = int.bitwise_exclusive_or(x, y)
  // y: y^x^y (x)
  let x = int.bitwise_exclusive_or(y, x)
  // y^x^x
  //
  assert x == 420
  assert y == 42
}
