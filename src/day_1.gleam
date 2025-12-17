import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

const starting_position = 50

const num_steps = 100

pub fn calculate_zero_stops(rotations: List(Int)) -> Int {
  let log_file = "inputs/day_1_log.txt"
  let _ = simplifile.delete(log_file)
  let assert Ok(_) = simplifile.create_file(log_file)

  let #(_final_position, zero_stops) =
    rotations
    |> list.fold(#(starting_position, 0), fn(acc, rotation) {
      let #(current_pos, zero_stop) = acc
      let new_pos = rotate(current_pos, rotation)
      let log_line =
        int.to_string(current_pos)
        <> " > "
        <> int.to_string(rotation)
        <> " -> "
        <> int.to_string(new_pos)
        <> " ("
        <> int.to_string(zero_stop)
        <> ")"
        <> "\n"
      let assert Ok(_) = simplifile.append(log_file, log_line)
      case new_pos {
        0 -> #(new_pos, zero_stop + 1)
        _ -> #(new_pos, zero_stop)
      }
    })

  zero_stops
}

pub fn calculate_all_zero_passes(rotations: List(Int)) -> Int {
  let #(_final_position, zero_passes) =
    rotations
    |> list.fold(#(starting_position, 0), fn(acc, rotation) {
      let #(current_pos, zero_passes) = acc
      let #(new_pos, new_zero_passes) = passes_start(current_pos, rotation)
      #(new_pos, zero_passes + new_zero_passes)
    })

  zero_passes
}

pub fn passes_start(current_pos: Int, rotation: Int) -> #(Int, Int) {
  passes(current_pos, rotation, 0)
}

pub fn passes(
  current_pos: Int,
  rotation: Int,
  current_passes: Int,
) -> #(Int, Int) {
  let neg_steps = int.negate(num_steps)
  case rotation {
    rot if rot > neg_steps && rot < num_steps -> {
      let #(new_pos, zero_passes) = passy(current_pos, rotation)
      #(new_pos, zero_passes + current_passes)
    }
    rot if rot <= neg_steps ->
      passes(current_pos, rotation + num_steps, current_passes + 1)
    _rot -> passes(current_pos, rotation - num_steps, current_passes + 1)
  }
}

pub fn passy(current_pos: Int, rotation: Int) -> #(Int, Int) {
  let new_pos = current_pos + rotation

  let zero_pos_pass = case current_pos == 0 {
    True -> 0
    False -> 1
  }

  case new_pos {
    p if p < 0 -> #(p + num_steps, zero_pos_pass)
    p if p > { num_steps - 1 } -> #(p - num_steps, 1)
    p if p == 0 -> #(p, 1)
    p -> #(p, 0)
  }
}

pub fn rotate_and_count_zero_passes(
  current_pos: Int,
  rotation: Int,
) -> #(Int, Int) {
  let assert Ok(full_turns) =
    int.divide(rotation, num_steps) |> result.map(int.absolute_value)

  let rest_rotation = case rotation < 0 {
    True -> rotation + full_turns * num_steps
    False -> rotation - full_turns * num_steps
  }

  let new_pos = current_pos + rest_rotation

  case new_pos {
    p if p < 0 -> #(p + num_steps, full_turns + 1)
    p if p > { num_steps - 1 } -> #(p - num_steps, full_turns + 1)
    p if p == 0 -> #(p, full_turns + 1)
    p -> #(p, full_turns)
  }
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
