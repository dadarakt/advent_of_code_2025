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
