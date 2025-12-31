import day_10
import gleam/int
import gleam/list
import gleam/result

const test_input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

pub fn parsing_test() {
  let machines = day_10.parse_instructions(test_input)
  assert 3 == list.length(machines)

  let assert [m, ..] = machines
  assert [False, True, True, False] == m.desired_indicators
  assert [[3], [1, 3], [2], [2, 3], [0, 2], [0, 1]] == m.buttons
  assert [3, 5, 4, 7] == m.joltage_requirements
}

pub fn solve_toggles_test() {
  let machines = day_10.parse_instructions(test_input)
  let assert [m, ..] = machines

  let assert Ok(solved_state) = day_10.solve_toggles(m)
  assert 2 == list.length(solved_state.button_presses)

  let solutions = machines |> list.map(day_10.solve_toggles)

  assert 7
    == solutions
    |> result.values()
    |> list.map(fn(s) { list.length(s.button_presses) })
    |> int.sum
}

pub fn solve_joltages_test() {
  let machines = day_10.parse_instructions(test_input)
  let assert [m, ..] = machines

  let assert Ok(solved_state) = day_10.solve_joltages(m)
  assert 10 == solved_state.button_presses
}

pub fn solve_a_star_test() {
  let machines = day_10.parse_instructions(test_input)
  let assert [m, ..] = machines

  let path = day_10.solve_joltage_with_a_star(m)
  assert 10 == list.length(path)
  echo path
}
