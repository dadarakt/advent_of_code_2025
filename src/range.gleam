import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string

pub type Range {
  Range(from: Int, to: Int)
}

pub fn enumerate(range: Range) -> List(Int) {
  enumerate_loop(range, range.from)
}

fn enumerate_loop(range: Range, idx: Int) -> List(Int) {
  case idx > range.to {
    True -> []
    False -> {
      [idx, ..enumerate_loop(range, idx + 1)]
    }
  }
}

/// parses a single range from a string
pub fn from_string(str: String) -> Range {
  let assert Ok(#(from_string, to_string)) = string.split_once(str, "-")
  let assert Ok(from) = int.parse(from_string)
  let assert Ok(to) = int.parse(to_string)

  Range(from, to)
}

/// parses all ranges which can be found in a string based on a regex
pub fn all_from_string(str: String) -> List(Range) {
  let assert Ok(regex) = regexp.from_string("([0-9]+)-([0-9]+)")
  regexp.scan(regex, str)
  |> list.map(fn(m) {
    let assert [option.Some(from), option.Some(to)] = m.submatches
    let assert Ok(from) = int.parse(from)
    let assert Ok(to) = int.parse(to)
    Range(from, to)
  })
}
