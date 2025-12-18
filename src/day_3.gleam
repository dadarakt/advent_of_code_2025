import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import day_2
import inputs

pub fn main() -> Nil {
  let banks = inputs.input_for_day(3, parse_banks_from_string)

  // part 1
  let sum_2 = sum_joltages(banks, 2)
  io.println(
    "The summed maximal joltage of length 2 is: " <> int.to_string(sum_2),
  )

  // part 2
  let sum_12 = sum_joltages(banks, 12)
  io.println(
    "The summed maximal joltage of length 12 is: " <> int.to_string(sum_12),
  )

  Nil
}

pub fn sum_joltages(banks: List(Int), n: Int) -> Int {
  banks
  |> list.map(fn(bank) { largest_joltage_for_bank_int(bank, n) })
  |> int.sum
}

pub fn parse_banks_from_string(input: String) -> List(Int) {
  string.split(input, "\n")
  |> list.map(int.parse)
  |> result.values()
}

pub fn largest_joltage_for_bank_int(bank: Int, n: Int) -> Int {
  day_2.number_to_digits(bank)
  |> largest_n_value_sum(n, 0)
}

pub fn largest_n_value_sum(bank: List(Int), n: Int, sum: Int) -> Int {
  case n {
    0 -> sum
    n -> {
      let bank_with_reserved_end = list.take(bank, list.length(bank) - n + 1)
      let #(max, idx) = find_max_with_idx(bank_with_reserved_end)
      let factor = list.repeat(10, n - 1) |> list.fold(1, fn(a, b) { a * b })
      let bank_after_idx = list.drop(bank, idx + 1)
      factor * max + largest_n_value_sum(bank_after_idx, n - 1, sum)
    }
  }
}

fn find_max_with_idx(l: List(Int)) {
  list.index_fold(l, #(0, 0), fn(acc, item, index) {
    let #(max, _idx) = acc
    case item > max {
      True -> #(item, index)
      False -> acc
    }
  })
}
