import day_1
import gleam/int
import gleam/io

pub fn main() -> Nil {
  io.println("Hello from advent_of_code_2025!")
  io.println("=========== Day 01 ===========")
  let rotations =
    day_1.parse_input_from_file("inputs/day_1.txt")
    |> day_1.calculate_0_passes()

  io.println("The password is " <> int.to_string(rotations))

  Nil
}
