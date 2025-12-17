import gleam/int
import gleam/io
import gleam/list
import gleam/result

const starting_position = 50

const num_steps = 100

pub fn calculate_0_passes(inputs: List(String)) -> Int {
  let rotations = parse_rotations(inputs)

  let #(_final_position, zero_passes) =
    rotations
    |> list.fold(#(starting_position, 0), fn(acc, rotation) {
      let #(current_pos, zero_passes) = acc
      let new_pos = rotate(current_pos, rotation)
      case new_pos {
        0 -> #(new_pos, zero_passes + 1)
        _ -> #(new_pos, zero_passes)
      }
    })

  zero_passes
}

pub fn rotate(current_pos: Int, rotation: Int) -> Int {
  let new_pos = current_pos + rotation

  case new_pos {
    new_pos if new_pos < 0 -> new_pos + num_steps
    new_pos if new_pos > { num_steps - 1 } -> new_pos - num_steps
    _ -> new_pos
  }
}

pub fn parse_rotations(inputs: List(String)) -> List(Int) {
  inputs
  |> list.map(parse_rotation)
  |> result.values
}

pub fn parse_rotation(input: String) -> Result(Int, Nil) {
  case input {
    "L" <> number_string -> int.parse(number_string) |> result.map(fn(x) { -x })
    "R" <> number_string -> int.parse(number_string)
    _ -> Error(Nil)
  }
}
