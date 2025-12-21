import gleam/int
import gleam/io
import gleam/set
import gleam/string

import inputs

pub fn main() {
  let state = inputs.input_for_day(7, parse_manifold)

  io.println(
    "The beam will be split " <> state.splits |> int.to_string <> " times",
  )
}

pub type Manifold {
  Empty
  Input(col: Int, next: Manifold)
  Splitter(left: Manifold, right: Manifold)
  Terminal(col: Int)
}

pub type ParsingState {
  ParsingState(beams: set.Set(Int), splits: Int)
}

pub fn parse_manifold(str: String) {
  string.split(str, "\n")
  |> parse_lines
}

fn parse_lines(lines: List(String)) {
  parse_lines_loop(lines, ParsingState(set.new(), 0))
}

fn parse_lines_loop(lines: List(String), state: ParsingState) {
  case lines {
    [] -> state
    [head, ..rest] -> parse_lines_loop(rest, apply_line(head, state))
  }
}

fn apply_line(line: String, state: ParsingState) -> ParsingState {
  let graphemes = line |> string.to_graphemes()
  apply_line_loop(graphemes, 0, state)
}

fn apply_line_loop(
  graphemes: List(String),
  idx: Int,
  state: ParsingState,
) -> ParsingState {
  case graphemes {
    [] -> state
    [head, ..rest] -> {
      case head {
        "S" -> {
          let new_state =
            ParsingState(..state, beams: set.insert(state.beams, idx))
          apply_line_loop(rest, idx + 1, new_state)
        }
        "^" -> {
          case set.contains(state.beams, idx) {
            True -> {
              let new_beams =
                state.beams
                |> set.delete(idx)
                |> set.insert(idx - 1)
                |> set.insert(idx + 1)

              apply_line_loop(
                rest,
                idx + 1,
                ParsingState(new_beams, state.splits + 1),
              )
            }
            False -> {
              apply_line_loop(rest, idx + 1, state)
            }
          }
        }
        _ -> apply_line_loop(rest, idx + 1, state)
      }
    }
  }
}
