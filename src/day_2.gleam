import gleam/int
import gleam/io
import gleam/list
import gleam/string

import inputs
import range

pub fn main() -> Nil {
  let ranges = inputs.input_for_day(2, range.all_from_string)
  let sum = sum_invalid_ids_in_ranges(ranges, made_of_two_same_numbers)

  io.println("The sum of invalid IDs (part 1): " <> int.to_string(sum))

  let sum_of_repeated =
    sum_invalid_ids_in_ranges(ranges, made_of_repeated_numbers)

  io.println(
    "The sum of invalid IDs (part 2): " <> int.to_string(sum_of_repeated),
  )
}

pub fn sum_invalid_ids_in_ranges(
  ranges: List(range.Range),
  invalid_id_fun: fn(Int) -> Bool,
) -> Int {
  ranges
  |> list.fold(0, fn(acc, range) {
    acc + sum_invalid_ids_in_range(range, invalid_id_fun)
  })
}

pub fn sum_invalid_ids_in_range(
  range: range.Range,
  invalid_id_fun: fn(Int) -> Bool,
) -> Int {
  invalid_ids_in_range(range, invalid_id_fun)
  |> list.fold(0, fn(acc, id) { acc + id })
}

pub fn invalid_ids_in_range(
  range: range.Range,
  invalid_id_fun: fn(Int) -> Bool,
) -> List(Int) {
  range.enumerate(range)
  |> list.filter(invalid_id_fun)
}

pub fn is_valid_id(number: Int) -> Bool {
  let digits = number_to_digits(number)
  !has_duplicate_loop(digits, 1)
}

pub fn made_of_two_same_numbers(number: Int) -> Bool {
  let str = int.to_string(number)
  let graphemes = string.to_graphemes(str)
  let len = list.length(graphemes)
  case len {
    n if n % 2 == 1 -> False
    _n -> {
      let #(first, second) = list.split(graphemes, len / 2)
      first == second
    }
  }
}

pub fn made_of_repeated_numbers(number: Int) {
  let digits = number_to_digits(number)
  made_of_repeated_numbers_recursion(digits, 1)
}

fn made_of_repeated_numbers_recursion(
  digits: List(Int),
  pattern_length: Int,
) -> Bool {
  let len = list.length(digits)
  case pattern_length > list.length(digits) / 2 {
    True -> False
    False -> {
      case len % pattern_length == 0 {
        False -> made_of_repeated_numbers_recursion(digits, pattern_length + 1)
        True -> {
          let assert [chunk, ..other_chunks] =
            list.sized_chunk(digits, pattern_length)
          list.all(other_chunks, fn(other_chunk) { other_chunk == chunk })
          || made_of_repeated_numbers_recursion(digits, pattern_length + 1)
        }
      }
    }
  }
}

pub fn has_duplicate_loop(digits: List(Int), length: Int) -> Bool {
  case length / 2 > list.length(digits) {
    True -> False
    False -> {
      has_duplicate_of_length(digits, length)
      || has_duplicate_loop(digits, length + 1)
    }
  }
}

pub fn has_duplicate_of_length(digits: List(Int), length: Int) {
  list.window(digits, length * 2)
  |> list.any(fn(slice) {
    let #(first, second) = list.split(slice, length)
    first == second
  })
}

pub fn number_to_digits(number: Int) -> List(Int) {
  number_to_digits_loop(number, [])
  |> list.reverse
}

fn number_to_digits_loop(number: Int, current_digits: List(Int)) -> List(Int) {
  case number {
    n if n < 10 -> [n, ..current_digits]
    n -> {
      let assert Ok(digit) = int.modulo(n, 10)
      let assert Ok(rest) = int.divide(n, 10)
      [digit, ..number_to_digits_loop(rest, current_digits)]
    }
  }
}
