import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import day_2
import inputs

pub fn main() -> Nil {
  let sum =
    inputs.input_for_day(3, parse_banks_from_string)
    |> list.map(largest_joltage_for_bank_int)
    |> int.sum

  io.println("The summed maximal joltage is: " <> int.to_string(sum))
  Nil
}

pub fn parse_banks_from_string(input: String) -> List(Int) {
  string.split(input, "\n")
  |> list.map(int.parse)
  |> result.values()
}

pub fn largest_joltage_for_bank_int(bank: Int) -> Int {
  echo bank
  let joltage =
    day_2.number_to_digits(bank)
    |> largest_joltage_for_bank

  echo joltage
  joltage
}

pub fn largest_joltage_for_bank(bank: List(Int)) -> Int {
  largest_joltage_for_bank_loop(bank, -1, -1)
}

fn largest_joltage_for_bank_loop(
  bank: List(Int),
  first: Int,
  second: Int,
) -> Int {
  case bank {
    [] -> {
      first * 10 + second
    }
    [a] -> {
      case a > second {
        True -> first * 10 + a
        False -> first * 10 + second
      }
    }
    [a, b] -> {
      case a > first {
        True -> a * 10 + b
        False -> {
          case b > second {
            True -> first * 10 + b
            False -> first * 10 + second
          }
        }
      }
    }
    [a, ..rest] -> {
      case a > first {
        True -> largest_joltage_for_bank_loop(rest, a, -1)
        False -> {
          case a > second {
            True -> largest_joltage_for_bank_loop(rest, first, a)
            False -> largest_joltage_for_bank_loop(rest, first, second)
          }
        }
      }
    }
  }
}
