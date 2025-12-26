import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string

pub type Machine {
  Machine(
    desired_indicators: List(Bool),
    buttons: List(List(Int)),
    joltage_requirements: List(Int),
  )
}

pub fn solve_machine(m: Machine) {
  let state =
    m.desired_indicators
    |> list.map(fn(_) { False })

  breadth_first_solve([#(state, 0)], m)
}

pub fn breadth_first_solve(queue: List(#(List(Bool), Int)), m: Machine) {
  case queue {
    [] -> Error("No Solution possible")
    [first, ..rest] -> {
      let #(state, steps) = first
      case state == m.desired_indicators {
        True -> Ok(steps)
        False -> {
          let new_states =
            m.buttons
            |> list.map(fn(b) { #(apply_button(state, b), steps + 1) })

          let new_queue = list.append(rest, new_states)
          breadth_first_solve(new_queue, m)
        }
      }
    }
  }
}

fn apply_button(state: List(Bool), button: List(Int)) -> List(Bool) {
  button
  |> list.fold(state, fn(acc, b) {
    let #(before, rest) = list.split(acc, b)
    let assert [i, ..after] = rest

    before
    |> list.append([!i, ..after])
  })
}

pub fn parse_instructions(str: String) -> List(Machine) {
  string.split(str, "\n")
  |> list.map(parse_machine)
}

pub fn parse_machine(str: String) {
  let assert Ok(indicator_regex) = regexp.from_string("\\[[\\.#]+\\]")
  let assert [indicator_lights] =
    regexp.scan(indicator_regex, str)
    |> list.map(fn(m) {
      m.content
      |> string.to_graphemes
      |> list.map(fn(s) {
        case s {
          "#" -> Ok(True)
          "." -> Ok(False)
          _ -> Error(Nil)
        }
      })
      |> result.values
    })

  let assert Ok(button_regex) = regexp.from_string("\\(([\\d,]+)\\)")
  let buttons =
    regexp.scan(button_regex, str)
    |> list.map(fn(m) {
      let assert [match] =
        m.submatches
        |> option.values

      string.split(match, ",")
      |> list.map(int.parse)
      |> result.values
    })

  let assert Ok(joltage_regex) = regexp.from_string("\\{[\\d,]+\\}")
  let assert [requirement] =
    regexp.scan(joltage_regex, str)
    |> list.map(fn(m) {
      m.content
      |> string.to_graphemes
      |> list.map(int.parse)
      |> result.values
    })

  Machine(indicator_lights, buttons, requirement)
}
