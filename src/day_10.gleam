import gleam/dict.{type Dict}
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

pub type JoltageSearchState {
  JoltageSearchState(joltage_state: Dict(Int, Int), button_presses: Int)
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
    "The total number of button presses for toggles is "
    <> int.to_string(sum_of_steps),
  )

  let solutions = machines |> list.map(solve_joltages)
  let sum_of_steps =
    solutions
    |> result.values()
    |> list.map(fn(s) { s.button_presses })
    |> int.sum

  io.println(
    "The total number of button presses for joltags is "
    <> int.to_string(sum_of_steps),
  )
}

pub fn backtrack_joltage(m: Machine) {
  let next_states_fun = fn(state: JoltageSearchState) {
    m.buttons
    |> list.flat_map(fn(b) {
      // try apply button many times
      [
        JoltageSearchState(
          apply_joltage_button(state.joltage_state, b, 10),
          state.button_presses + 10,
        ),
        JoltageSearchState(
          apply_joltage_button(state.joltage_state, b, 5),
          state.button_presses + 5,
        ),
        JoltageSearchState(
          apply_joltage_button(state.joltage_state, b, 1),
          state.button_presses + 1,
        ),
      ]
    })
  }
}

/// This won't be feasible here, as we need the optimal solution, not just any solution
pub fn backtrack(
  state: s,
  _next: fn(s) -> List(s),
  _admissable: fn(s) -> Bool,
) -> s {
  state
}

pub fn solve_joltages(m: Machine) {
  let joltage_state =
    m.joltage_requirements
    |> list.index_map(fn(_, i) { #(i, 0) })
    |> dict.from_list()

  let search_state = JoltageSearchState(joltage_state, 0)
  let next_states_fun = fn(state: JoltageSearchState) {
    m.buttons
    |> list.flat_map(fn(b) {
      // try apply button many times
      [
        JoltageSearchState(
          apply_joltage_button(state.joltage_state, b, 10),
          state.button_presses + 10,
        ),
        JoltageSearchState(
          apply_joltage_button(state.joltage_state, b, 5),
          state.button_presses + 5,
        ),
        JoltageSearchState(
          apply_joltage_button(state.joltage_state, b, 1),
          state.button_presses + 1,
        ),
      ]
    })
    |> list.filter(validate_state(_, m))
  }

  let desired_dict =
    m.joltage_requirements
    |> list.index_map(fn(x, i) { #(i, x) })
    |> dict.from_list()

  let eval_fun = fn(state: JoltageSearchState) {
    state.joltage_state == desired_dict
  }

  echo breadth_first_solve(
    [search_state],
    next_states_fun,
    eval_fun,
    hash_joltages,
    set.new(),
  )
}

fn validate_state(s: JoltageSearchState, m: Machine) {
  m.joltage_requirements
  |> list.index_map(fn(v, i) { #(i, v) })
  |> list.all(fn(t) {
    let #(key, value) = t
    let current_value = dict.get(s.joltage_state, key) |> result.unwrap(0)
    current_value <= value
  })
}

pub fn solve_toggles(m: Machine) {
  let indicator_state =
    m.desired_indicators
    |> list.map(fn(_) { False })

  let search_state = ToggleSearchState(indicator_state, [])
  let next_states_fun = fn(state: ToggleSearchState) {
    m.buttons
    |> list.index_map(fn(b, i) {
      ToggleSearchState(apply_toggle_button(state.indicator_state, b), [
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

fn hash_joltages(state: JoltageSearchState) {
  state.joltage_state
  |> dict.to_list()
  |> list.sort(fn(a, b) {
    let #(a_key, _) = a
    let #(b_key, _) = b
    int.compare(a_key, b_key)
  })
  |> list.map(fn(t) {
    let #(_, val) = t
    val
  })
  |> hash_int_list()
}

fn hash_int_list(l: List(Int)) {
  case l {
    [] -> 0
    [first, ..rest] -> hash_int_list(rest) * 31 + first
  }
}

fn apply_joltage_button(
  state: Dict(Int, Int),
  button: List(Int),
  times: Int,
) -> Dict(Int, Int) {
  button
  |> list.fold(state, fn(acc, b) {
    dict.upsert(acc, b, fn(x) {
      case x {
        option.None -> times
        option.Some(val) -> val + times
      }
    })
  })
}

fn apply_toggle_button(state: List(Bool), button: List(Int)) -> List(Bool) {
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
