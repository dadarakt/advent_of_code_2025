import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string

import gleam/io

import inputs

pub type Machine {
  Machine(
    desired_indicators: List(Bool),
    buttons: List(List(Int)),
    joltage_requirements: List(Int),
  )
}

pub type SearchState {
  SearchState(indicator_state: List(Bool), button_presses: List(Int))
}

pub fn main() {
  let machines = inputs.input_for_day(10, parse_instructions)

  let solutions = machines |> list.map(solve_machine)
  let sum_of_steps =
    solutions |> result.values() |> list.map(list.length) |> int.sum

  io.println(
    "The total number of button presses is " <> int.to_string(sum_of_steps),
  )
}

pub fn solve_machine(m: Machine) {
  let indicator_state =
    m.desired_indicators
    |> list.map(fn(_) { False })

  let search_state = SearchState(indicator_state, [])

  echo breadth_first_solve([search_state], m, set.new())
}

pub fn breadth_first_solve(
  queue: List(SearchState),
  m: Machine,
  seen_state_hashes: Set(Int),
) {
  case queue {
    [] -> Error("No Solution possible")
    [first, ..rest] -> {
      case first.indicator_state == m.desired_indicators {
        True -> Ok(first.button_presses)
        False -> {
          let state_hash = hash_state(first.indicator_state)
          case set.contains(seen_state_hashes, state_hash) {
            True -> breadth_first_solve(rest, m, seen_state_hashes)
            False -> {
              let new_states =
                m.buttons
                |> list.index_map(fn(b, i) {
                  let new_state = apply_button(first.indicator_state, b)
                  SearchState(new_state, [i, ..first.button_presses])
                })

              let new_queue = list.append(rest, new_states)
              breadth_first_solve(
                new_queue,
                m,
                set.insert(seen_state_hashes, state_hash),
              )
            }
          }
        }
      }
    }
  }
}

fn hash_state(state: List(Bool)) {
  case state {
    [] -> 0
    [first, ..rest] -> {
      case first {
        True -> int.bitwise_shift_left(hash_state(rest), 1) + 1
        False -> int.bitwise_shift_left(hash_state(rest), 1)
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
  |> list.filter(fn(l) { l != "" })
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
