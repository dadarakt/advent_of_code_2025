import gleam/list
import gleam/string

import inputs

pub fn main() -> Nil {
  let roll_matrix = inputs.input_for_day(4, parse_rolls)
  echo roll_matrix

  Nil
}

pub fn parse_rolls(input: String) -> List(List(Int)) {
  string.split(input, "\n")
  |> list.map(fn(l) {
    string.to_graphemes(l)
    |> list.map(fn(g) {
      case g {
        "@" -> 1
        _ -> 0
      }
    })
  })
}

pub fn sub_matrix(
  matrix: List(List(a)),
  rows: #(Int, Int),
  cols: #(Int, Int),
) -> List(List(a)) {
  let #(row_start, row_end) = rows
  let #(col_start, col_end) = cols

  assert row_start <= row_end
  assert col_start <= col_end

  matrix
  |> list.drop(row_start)
  |> list.take(row_end - row_start + 1)
  |> list.map(fn(r) {
    r
    |> list.drop(col_start)
    |> list.take(col_end - col_start + 1)
  })
}
