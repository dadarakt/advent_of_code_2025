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

pub type ToggleSearchState {
  ToggleSearchState(indicator_state: List(Bool), button_presses: List(Int))
}

pub fn main() {
  let machines = inputs.input_for_day(10, parse_instructions)

  let solutions = machines |> list.map(solve_toggles)
  let sum_of_steps =
    solutions
    |> result.values()
    |> list.map(fn(s) { list.length(s.button_presses) })
    |> int.sum

  io.println(
    "The total number of button presses is " <> int.to_string(sum_of_steps),
  )
}

pub fn solve_toggles(m: Machine) {
  let indicator_state =
    m.desired_indicators
    |> list.map(fn(_) { False })

  let search_state = ToggleSearchState(indicator_state, [])
  let next_states_fun = fn(state: ToggleSearchState) {
    m.buttons
    |> list.index_map(fn(b, i) {
      ToggleSearchState(apply_button(state.indicator_state, b), [
        i,
        ..state.button_presses
      ])
    })
  }

  let eval_fun = fn(state: ToggleSearchState) {
    state.indicator_state == m.desired_indicators
  }
  breadth_first_solve(
    [search_state],
    next_states_fun,
    eval_fun,
    hash_toggles,
    set.new(),
  )
}

pub fn breadth_first_solve(
  queue: List(s),
  next_states_fun: fn(s) -> List(s),
  eval_fun: fn(s) -> Bool,
  hash_state_fun: fn(s) -> Int,
  seen_state_hashes: Set(Int),
) -> Result(s, String) {
  case queue {
    [] -> Error("No Solution possible")
    [state, ..rest] -> {
      case eval_fun(state) {
        True -> Ok(state)
        False -> {
          let #(seen_hashes, new_states) =
            next_states_fun(state)
            |> list.fold(#(seen_state_hashes, []), fn(acc, s) {
              let #(hashes, states) = acc
              let hash = hash_state_fun(s)

              case set.contains(hashes, hash) {
                True -> #(hashes, states)
                False -> #(set.insert(hashes, hash), [s, ..states])
              }
            })

          let updated_queue = list.append(rest, new_states)

          breadth_first_solve(
            updated_queue,
            next_states_fun,
            eval_fun,
            hash_state_fun,
            seen_hashes,
          )
        }
      }
    }
  }
}

fn hash_toggles(state: ToggleSearchState) {
  hash_toggles_loop(state.indicator_state)
}

fn hash_toggles_loop(toggles: List(Bool)) {
  case toggles {
    [] -> 0
    [first, ..rest] -> {
      case first {
        True -> int.bitwise_shift_left(hash_toggles_loop(rest), 1) + 1
        False -> int.bitwise_shift_left(hash_toggles_loop(rest), 1)
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
