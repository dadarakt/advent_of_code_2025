import day_1
import gleam/int
import gleam/io

pub fn main() -> Nil {
  io.println("=========== Day 01 ===========")
  let rotations = day_1.parse_input_from_file("inputs/day_1.txt")

  let zero_stops = day_1.calculate_zero_stops(rotations)

  io.println("Stopped at zero: " <> int.to_string(zero_stops))

  let zero_passes = day_1.calculate_all_zero_passes(rotations)

  io.println("Zero passes : " <> int.to_string(zero_passes))
  Nil
}
