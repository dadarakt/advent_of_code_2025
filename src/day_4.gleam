import gleam/int
import gleam/io
import gleam/list
import gleam/string

import inputs

pub fn main() -> Nil {
  let rolls = inputs.input_for_day(4, parse_rolls)

  // part 1 
  let removable_rolls_count = count_removable_rolls(rolls)
  io.println(
    "There are " <> int.to_string(removable_rolls_count) <> " removable rolls.",
  )

  // part 2 
  let removable_rolls_count = count_removable_rolls_repeated(rolls, 0)
  io.println(
    "There are "
    <> int.to_string(removable_rolls_count)
    <> " removable rolls when repeating",
  )

  Nil
}

pub fn count_removable_rolls(rolls: List(List(Int))) -> Int {
  let assert [first_row, ..] = rolls
  let dimensions = #(list.length(rolls), list.length(first_row))
  count_removable_rolls_loop(rolls, dimensions, #(0, 0), 0)
}

pub fn count_removable_rolls_repeated(
  rolls: List(List(Int)),
  initial_sum: Int,
) -> Int {
  let assert [first_row, ..] = rolls
  let dimensions = #(list.length(rolls), list.length(first_row))
  let initial_acc = Accumulator(0, 0, 0, rolls)
  let acc = remove_and_return(rolls, dimensions, initial_acc)

  case acc.num_removals == 0 {
    True -> initial_sum
    False ->
      count_removable_rolls_repeated(
        acc.updated_rolls,
        initial_sum + acc.num_removals,
      )
  }
}

pub type Accumulator {
  Accumulator(
    row_idx: Int,
    col_idx: Int,
    num_removals: Int,
    updated_rolls: List(List(Int)),
  )
}

fn remove_and_return(
  rolls: List(List(Int)),
  dimensions: #(Int, Int),
  acc: Accumulator,
) -> Accumulator {
  let row_idx = acc.row_idx
  let col_idx = acc.col_idx
  let #(num_rows, num_cols) = dimensions

  case row_idx < num_rows {
    False -> acc
    True ->
      case col_idx < num_cols {
        True -> {
          // a bit clumsy, but let's try naive version first
          let assert [[pos]] =
            sub_matrix(rolls, #(row_idx, row_idx), #(col_idx, col_idx))

          let new_removals = case pos {
            1 -> {
              let sub_matrix =
                sub_matrix(rolls, #(row_idx - 1, row_idx + 1), #(
                  col_idx - 1,
                  col_idx + 1,
                ))

              // -1 to remove roll at current pos
              case sum_matrix(sub_matrix, int.add) - 1 {
                n if n < 4 -> 1
                _ -> 0
              }
            }
            _ -> 0
          }

          case new_removals == 0 {
            True ->
              remove_and_return(
                rolls,
                dimensions,
                Accumulator(..acc, col_idx: col_idx + 1),
              )
            False ->
              remove_and_return(
                rolls,
                dimensions,
                Accumulator(
                  ..acc,
                  col_idx: acc.col_idx + 1,
                  num_removals: acc.num_removals + new_removals,
                  updated_rolls: update_matrix(
                    acc.updated_rolls,
                    #(row_idx, col_idx),
                    0,
                  ),
                ),
              )
          }
        }
        False -> {
          remove_and_return(
            rolls,
            dimensions,
            Accumulator(..acc, row_idx: acc.row_idx + 1, col_idx: 0),
          )
        }
      }
  }
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

pub fn update_matrix(
  matrix: List(List(a)),
  idx: #(Int, Int),
  value: a,
) -> List(List(a)) {
  let #(row, col) = idx
  let rows_before = list.take(matrix, row)
  let assert [current_row, ..rows_after] = list.drop(matrix, row)

  let row_before = list.take(current_row, col)
  let row_after = list.drop(current_row, col + 1)
  let updated_row = list.append(row_before, [value, ..row_after])

  list.append(rows_before, [updated_row, ..rows_after])
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
