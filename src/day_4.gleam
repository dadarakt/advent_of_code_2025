import gleam/int
import gleam/io
import gleam/list
import gleam/string

import inputs

pub fn main() -> Nil {
  let rolls = inputs.input_for_day(4, parse_rolls)
  let removable_rolls_count = count_removable_rolls(rolls)

  io.println(
    "There are " <> int.to_string(removable_rolls_count) <> " removable rolls.",
  )

  Nil
}

pub fn count_removable_rolls(rolls: List(List(Int))) -> Int {
  let assert [first_row, ..] = rolls
  let dimensions = #(list.length(rolls), list.length(first_row))
  count_removable_rolls_loop(rolls, dimensions, #(0, 0), 0)
}

fn count_removable_rolls_loop(
  rolls: List(List(Int)),
  dimensions: #(Int, Int),
  idx: #(Int, Int),
  acc: Int,
) {
  let #(row_idx, col_idx) = idx
  let #(num_rows, num_cols) = dimensions

  case row_idx < num_rows {
    False -> acc
    True ->
      case col_idx < num_cols {
        True -> {
          // a bit clumsy, but let's try naive version first
          let assert [[pos]] =
            sub_matrix(rolls, #(row_idx, row_idx), #(col_idx, col_idx))

          let new_acc = case pos {
            1 -> {
              let sub_matrix =
                sub_matrix(rolls, #(row_idx - 1, row_idx + 1), #(
                  col_idx - 1,
                  col_idx + 1,
                ))

              // -1 to remove roll at current pos
              case sum_matrix(sub_matrix, int.add) - 1 {
                n if n < 4 -> acc + 1
                _ -> acc
              }
            }
            _ -> {
              acc
            }
          }

          count_removable_rolls_loop(
            rolls,
            dimensions,
            #(row_idx, col_idx + 1),
            new_acc,
          )
        }
        False -> {
          count_removable_rolls_loop(rolls, dimensions, #(row_idx + 1, 0), acc)
        }
      }
  }
}

pub fn sum_matrix(matrix: List(List(a)), sum_fun: fn(a, Int) -> Int) -> Int {
  matrix
  |> list.fold(0, fn(acc, r) {
    acc + list.fold(r, 0, fn(acc, c) { sum_fun(c, acc) })
  })
}

pub fn sub_matrix(
  matrix: List(List(a)),
  rows: #(Int, Int),
  cols: #(Int, Int),
) -> List(List(a)) {
  let #(row_start, row_end) = rows
  let #(col_start, col_end) = cols

  // sanitize inputs
  let row_start = int.min(row_start, row_end) |> int.max(0)
  let row_end = int.max(row_start, row_end) |> int.max(0)
  let col_start = int.min(col_start, col_end) |> int.max(0)
  let col_end = int.max(col_start, col_end) |> int.max(0)

  matrix
  |> list.drop(row_start)
  |> list.take(row_end - row_start + 1)
  |> list.map(fn(r) {
    r
    |> list.drop(col_start)
    |> list.take(col_end - col_start + 1)
  })
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
  |> list.filter(fn(row) {
    case row {
      [] -> False
      _ -> True
    }
  })
}
