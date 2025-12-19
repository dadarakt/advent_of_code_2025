import gleam/int
import gleam/list
import gleam/option
import gleam/order
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

pub fn in_range(range: Range, value: Int) -> Bool {
  value >= range.from && value <= range.to
}

pub fn are_disjoint(a: Range, b: Range) {
  a.to + 1 < b.from || b.to + 1 < a.from
}

pub fn merge_until_no_overlap(ranges: List(Range)) -> List(Range) {
  let merged_ranges =
    ranges
    |> list.sort(fn(a, b) { int.compare(a.from, b.to) })
    |> merge_ranges()

  case list.length(ranges) == list.length(merged_ranges) {
    True -> merged_ranges
    False -> merge_until_no_overlap(merged_ranges)
  }
}

pub fn merge_ranges(ranges: List(Range)) -> List(Range) {
  case ranges {
    [] -> []
    [_] as range -> range
    [a, b, ..rest] -> {
      case try_merge(a, b) {
        Ok(r) -> merge_ranges([r, ..rest])
        Error(Nil) -> [a, ..merge_ranges([b, ..rest])]
      }
    }
  }
}

pub fn size(range: Range) -> Int {
  range.to - range.from + 1
}

pub fn try_merge(a: Range, b: Range) -> Result(Range, Nil) {
  // truth table for comparisons of range delimiters
  let from_compare = int.compare(a.from, b.from)
  let to_compare = int.compare(a.to, b.to)

  case from_compare, to_compare {
    order.Lt, order.Lt -> {
      // find disjoint case
      case a.to + 1 < b.from {
        True -> Error(Nil)
        False -> Ok(Range(a.from, b.to))
      }
    }
    order.Lt, order.Eq | order.Lt, order.Gt -> Ok(a)
    order.Eq, order.Lt -> Ok(b)
    order.Eq, order.Eq | order.Eq, order.Gt -> Ok(a)
    order.Gt, order.Lt | order.Gt, order.Eq -> Ok(b)
    order.Gt, order.Gt -> {
      // find disjoint case
      case b.to + 1 < a.from {
        True -> Error(Nil)
        False -> Ok(Range(b.from, a.to))
      }
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
