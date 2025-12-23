import day_9

const test_input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

pub fn parsing_points_test() {
  assert [
      day_9.Point2D(7, 1),
      day_9.Point2D(11, 1),
      day_9.Point2D(11, 7),
      day_9.Point2D(9, 7),
      day_9.Point2D(9, 5),
      day_9.Point2D(2, 5),
      day_9.Point2D(2, 3),
      day_9.Point2D(7, 3),
    ]
    == day_9.points_from_string(test_input)
}

pub fn rectangle_creation_test() {
  assert 4
    == day_9.Rectangle(day_9.Point2D(1, 1), day_9.Point2D(3, 3))
    |> day_9.area()

  assert 4
    == day_9.Rectangle(day_9.Point2D(3, 3), day_9.Point2D(1, 1))
    |> day_9.area()

  assert 24 == day_9.rectangle_area(day_9.Point2D(2, 5), day_9.Point2D(9, 7))
  assert 35 == day_9.rectangle_area(day_9.Point2D(7, 1), day_9.Point2D(11, 7))
  assert 6 == day_9.rectangle_area(day_9.Point2D(7, 3), day_9.Point2D(2, 3))
  assert 50 == day_9.rectangle_area(day_9.Point2D(2, 5), day_9.Point2D(11, 1))
}

pub fn max_rectangle_test() {
  let input = day_9.points_from_string(test_input)
  assert 50 == day_9.maximal_rectangle(input)
}

pub fn print_tiles_test() {
  let input = day_9.points_from_string(test_input)
  day_9.print_tiles(input)
}

pub fn max_rectangle_in_polygon_test() {
  let input = day_9.points_from_string(test_input)
  // assert 24 == day_9.maximal_rectangle_in_polygon(input)
}
