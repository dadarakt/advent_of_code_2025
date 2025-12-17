import day_1
import gleeunit

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

pub fn main() -> Nil {
  gleeunit.main()
}

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
  assert 97 == day_1.rotate(99, -2)
  assert 0 == day_1.rotate(98, 2)
  assert 3 == day_1.rotate(98, 5)
}

pub fn zero_passes_test() {
  let zero_passes = day_1.calculate_0_passes(test_inputs)
  assert 3 == zero_passes
}
