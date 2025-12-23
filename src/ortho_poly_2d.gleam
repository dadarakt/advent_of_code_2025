import gleam/list
import gleam/result
import ortho_line_2d.{type OrthoLine2D}
import point_2d.{type Point2D}

pub type OrthoPoly2D {
  OrthoPoly2D(lines: List(OrthoLine2D))
}

/// constructs a poly by connecting the poinst in a circular manner. 
/// erros if the presented points to not form orthogonal lines
pub fn from_points(points: List(Point2D)) -> Result(OrthoPoly2D, Nil) {
  case points {
    [] | [_] -> Ok(OrthoPoly2D([]))
    [first, _, ..] -> {
      let lines = lines_from_points_loop(points, first)
      case list.all(lines, result.is_ok) {
        True -> Ok(OrthoPoly2D(result.values(lines)))
        False -> Error(Nil)
      }
    }
  }
}

fn lines_from_points_loop(points, first) {
  case points {
    [] -> []
    [last] -> [ortho_line_2d.new(last, first)]
    [first, second, ..rest] -> [
      ortho_line_2d.new(first, second),
      ..lines_from_points_loop([second, ..rest], first)
    ]
  }
}

pub fn is_point_within(poly: OrthoPoly2D, point: Point2D) {
  let outside_point = point_2d.Point2D(point.x, -100_000_000)
  let assert Ok(reference_line) = ortho_line_2d.new(point, outside_point)

  let num_crosses =
    list.fold(poly.lines, 0, fn(acc, l) {
      case ortho_line_2d.do_cross(reference_line, l) {
        True -> acc + 1
        False -> acc
      }
    })

  case num_crosses {
    c if c % 2 == 0 -> False
    _ -> True
  }
}
