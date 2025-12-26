import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string

pub type Machine {
  Machine(
    desired_indicators: List(Int),
    buttons: List(List(Int)),
    joltage_requirements: List(Int),
  )
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
      echo m.content
      m.content
      |> string.to_graphemes
      |> list.map(fn(s) {
        case s {
          "#" -> Ok(1)
          "." -> Ok(0)
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
