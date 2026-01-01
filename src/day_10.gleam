import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/set
import gleam/string
import search_algos

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

  let solutions = machines |> list.map(solve_joltage_with_a_star)
  let sum_of_steps =
    solutions
    |> list.map(fn(s) { list.length(s) })
    |> int.sum

  io.println(
    "The total number of button presses for joltags is "
    <> int.to_string(sum_of_steps),
  )
}

pub fn solve_joltages(m: Machine) {
  let joltage_state =
    m.joltage_requirements
    |> list.index_map(fn(_, i) { #(i, 0) })
    |> dict.from_list()

  let search_state = JoltageSearchState(joltage_state, 0)
  let next_states_fun = fn(state: JoltageSearchState) {
    m.buttons
    |> list.map(fn(b) {
      // try apply button many times
      JoltageSearchState(
        apply_joltage_button(state.joltage_state, b, 1),
        state.button_presses + 1,
      )
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

  search_algos.breadth_first_solve(
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
  search_algos.breadth_first_solve(
    [search_state],
    next_states_fun,
    eval_fun,
    hash_toggles,
    set.new(),
  )
}

pub type JoltageState {
  JoltageState(values: List(Int))
}

/// assume a button that increments all value at once
pub fn joltage_heuristic(m: Machine) -> fn(JoltageState) -> Int {
  fn(s: JoltageState) {
    let assert Ok(zipped) = list.strict_zip(m.joltage_requirements, s.values)

    let dist =
      zipped
      |> list.fold(0, fn(acc, t) {
        let #(target, value) = t
        target - value + acc
      })

    dist / list.length(m.joltage_requirements)
  }
}

pub fn solve_joltage_with_a_star(m: Machine) -> List(JoltageState) {
  echo m
  let init_values =
    m.joltage_requirements
    |> list.map(fn(_) { 0 })

  let start_state = JoltageState(values: init_values)

  let flat_buttons =
    m.buttons
    |> list.map(fn(b) {
      init_values
      |> list.index_map(fn(_v, i) {
        case list.contains(b, i) {
          True -> 1
          False -> 0
        }
      })
    })

  let next_states_fun = fn(state: JoltageState) {
    flat_buttons
    |> list.map(fn(b) {
      let new_values =
        list.zip(b, state.values)
        |> list.map(fn(t) {
          let #(a, b) = t
          a + b
        })

      let allowed =
        new_values
        |> list.zip(m.joltage_requirements)
        |> list.all(fn(t) {
          let #(value, target) = t
          target >= value
        })

      case allowed {
        True -> Ok(JoltageState(new_values))
        False -> {
          Error(Nil)
        }
      }
    })
    |> result.values
  }

  let assert Ok(result) =
    search_algos.a_star_search(
      start_state,
      JoltageState(m.joltage_requirements),
      joltage_heuristic(m),
      next_states_fun,
    )

  io.println(
    "solved machine in " <> list.length(result) |> int.to_string <> " steps",
  )
  result
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

  let assert Ok(joltage_regex) = regexp.from_string("\\{([\\d,]+)\\}")
  let assert [requirement] =
    regexp.scan(joltage_regex, str)
    |> list.map(fn(m) {
      let assert [match] =
        m.submatches
        |> option.values

      match
      |> string.split(",")
      |> list.map(int.parse)
      |> result.values
    })

  Machine(indicator_lights, buttons, requirement)
}
