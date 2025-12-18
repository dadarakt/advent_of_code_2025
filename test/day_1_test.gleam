import day_1

const test_inputs = [
  "L68",
  "L30",
  "R48",
  "L5",
  "R60",
  "L55",
  "L1",
  "L99",
  "R14",
  "L82",
]

// gleeunit test functions end in `_test`
pub fn parsing_test() {
  let parsed_inputs = day_1.parse_rotations(test_inputs)
  let expected = [-68, -30, 48, -5, 60, -55, -1, -99, 14, -82]

  assert expected == parsed_inputs
}

pub fn rotate_test() {
  assert 50 == day_1.rotate(50, 0)
  assert 30 == day_1.rotate(50, -20)
  assert 70 == day_1.rotate(50, 20)
  assert 99 == day_1.rotate(0, -1)
  assert 1 == day_1.rotate(0, 1)
  assert 0 == day_1.rotate(99, 1)
  assert 97 == day_1.rotate(99, -2)
  assert 0 == day_1.rotate(98, 2)
  assert 3 == day_1.rotate(98, 5)
  assert 98 == day_1.rotate(2, -4)
  assert 2 == day_1.rotate(99, 3)
  assert 95 == day_1.rotate(5, -10)
  assert 0 == day_1.rotate(95, 5)
  assert 19 == day_1.rotate(11, 8)
  assert 12 == day_1.rotate(12, 100)
  assert 12 == day_1.rotate(12, 200)
}

pub fn zero_stops_test() {
  let rotations = day_1.parse_rotations(test_inputs)
  let zero_stops = day_1.calculate_zero_stops(rotations)
  assert 3 == zero_stops
}

pub fn zero_passes_test() {
  let rotations = day_1.parse_rotations(test_inputs)
  let zero_passes = day_1.calculate_all_zero_passes(rotations)
  assert 6 == zero_passes
}
