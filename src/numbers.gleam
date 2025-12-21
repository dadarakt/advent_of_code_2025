//// Helpers to work with numbers and their digits

import gleam/int
import gleam/list

/// Turns an integer into the list of its digits
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
