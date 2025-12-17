import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

const starting_position = 50

const num_steps = 100

pub fn calculate_0_passes(rotations: List(Int)) -> Int {
  let log_file = "inputs/day_1_log.txt"
  let _ = simplifile.delete(log_file)
  let assert Ok(_) = simplifile.create_file(log_file)

  let #(_final_position, zero_passes) =
    rotations
    |> list.fold(#(starting_position, 0), fn(acc, rotation) {
      let #(current_pos, zero_passes) = acc
      let new_pos = rotate(current_pos, rotation)
      let log_line =
        int.to_string(current_pos)
        <> " > "
        <> int.to_string(rotation)
        <> " -> "
        <> int.to_string(new_pos)
        <> " ("
        <> int.to_string(zero_passes)
        <> ")"
        <> "\n"
      let assert Ok(_) = simplifile.append(log_file, log_line)
      case new_pos {
        0 -> #(new_pos, zero_passes + 1)
        _ -> #(new_pos, zero_passes)
      }
    })

  zero_passes
}

pub fn rotate(current_pos: Int, rotation: Int) -> Int {
  // modulo so that full rotations are left out
  let assert Ok(rotation) = int.modulo(rotation, num_steps)
  let new_pos = current_pos + rotation

  case new_pos {
    new_pos if new_pos < 0 -> new_pos + num_steps
    new_pos if new_pos > { num_steps - 1 } -> new_pos - num_steps
    _ -> new_pos
  }
}

pub fn parse_input_from_file(filepath: String) -> List(Int) {
  let assert Ok(file_content) = simplifile.read(from: filepath)
  string.split(file_content, "\n")
  |> parse_rotations()
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
