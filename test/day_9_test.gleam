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
