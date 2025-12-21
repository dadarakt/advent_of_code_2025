import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string

import inputs

pub type Op {
  Add
  Mul
}

pub type Problem {
  Problem(arguments: List(Int), op: Op)
}

pub type Worksheet {
  Worksheet(problems: List(Problem))
}

pub fn main() {
  let worksheet = inputs.input_for_day(6, parse_worksheet)
  let grand_total = sum_worksheet_solutions(worksheet)

  io.println(
    "The grand total of the worksheet is " <> int.to_string(grand_total),
  )

  let worksheet_cephalopod = inputs.input_for_day(6, parse_worksheet_cephalopod)
  let grand_total_cephalopod = sum_worksheet_solutions(worksheet_cephalopod)
  io.println(
    "The grand total the cephalopod way is "
    <> int.to_string(grand_total_cephalopod),
  )
}

pub fn sum_worksheet_solutions(worksheet: Worksheet) -> Int {
  worksheet.problems
  |> list.fold(0, fn(acc, problem) { acc + solve_problem(problem) })
}

pub fn solve_problem(problem: Problem) -> Int {
  case problem.op {
    Add -> int.sum(problem.arguments)
    Mul -> list.fold(problem.arguments, 1, fn(a, b) { a * b })
  }
}

pub fn map_worksheet_to_cephalopod(worksheet: Worksheet) -> Worksheet {
  let cephalopod_problems =
    worksheet.problems
    |> list.map(map_problem_to_cephalopod)

  Worksheet(cephalopod_problems)
}

fn map_problem_to_cephalopod(problem: Problem) -> Problem {
  Problem(..problem, arguments: args_to_cephalopod(problem.arguments))
}

pub fn args_to_cephalopod(args: List(Int)) -> List(Int) {
  let arg_digits =
    args
    |> list.map(number_to_digits)

  args_to_cephalopod_loop(arg_digits, [])
}

fn args_to_cephalopod_loop(
  number_digits: List(List(Int)),
  reformed: List(Int),
) -> List(Int) {
  case list.all(number_digits, list.is_empty) {
    True -> reformed
    False -> {
      let first_digits =
        number_digits
        |> list.map(fn(digits) {
          case digits {
            [] -> 0
            [first] -> first
            [first, ..] -> first
          }
        })

      let rests =
        number_digits
        |> list.map(fn(digits) { list.drop(digits, 1) })

      let new_reformed =
        reformed
        |> list.prepend(digits_to_int(first_digits))

      args_to_cephalopod_loop(rests, new_reformed)
    }
  }
}

fn digits_to_int(digits: List(Int)) -> Int {
  list.fold(digits, 0, fn(acc, d) { acc * 10 + d })
}

// todo make this a shared function
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

pub fn parse_worksheet_cephalopod(input: String) {
  let lines = string.split(input, "\n")
  let argument_lines =
    lines
    |> list.take(list.length(lines) - 2)

  let assert [ops_line] =
    lines
    |> list.drop(list.length(lines) - 2)
    |> list.take(1)

  let offsets = parse_offsets(ops_line)
  let arguments =
    parse_argument_lines_loop(offsets, argument_lines, []) |> list.reverse
  let parsed_ops: List(Op) =
    ops_line
    |> string.to_graphemes()
    |> list.fold([], fn(acc, g) {
      case g {
        "+" -> [Add, ..acc]
        "*" -> [Mul, ..acc]
        _ -> acc
      }
    })
    |> list.reverse()

  let problems =
    list.zip(parsed_ops, arguments)
    |> list.map(fn(zipped) {
      let #(op, args) = zipped
      Problem(args, op)
    })

  Worksheet(problems)
}

pub fn parse_argument_lines_loop(
  offsets: List(Int),
  lines: List(String),
  acc: List(List(Int)),
) -> List(List(Int)) {
  case offsets {
    [] -> acc
    [offset] -> {
      let numbers = blocks_to_numbers(lines)

      echo numbers

      [numbers, ..acc]
    }
    [offset, ..rest] -> {
      let blocks =
        lines
        |> list.map(fn(l) { string.slice(l, 0, offset - 1) })

      let numbers = blocks_to_numbers(blocks)

      let rest_lines =
        lines
        |> list.map(fn(l) { string.drop_start(l, offset) })

      let new_acc = [numbers, ..acc]

      parse_argument_lines_loop(rest, rest_lines, new_acc)
    }
  }
}

pub fn blocks_to_numbers(blocks: List(String)) -> List(Int) {
  let digit_lists =
    blocks
    |> list.map(string.to_graphemes)
    |> list.map(fn(graphemes) { list.map(graphemes, parse_int_or_minus_one) })
  blocks_to_number_loop(digit_lists, [])
}

fn blocks_to_number_loop(digit_lists: List(List(Int)), acc: List(Int)) {
  case list.first(digit_lists) {
    Ok([]) -> acc
    _ -> {
      let #(heads, rests) =
        digit_lists
        |> list.fold(#([], []), fn(acc, l) {
          let #(acc_heads, acc_rests) = acc
          let assert [h, ..rest] = l
          #([h, ..acc_heads], [rest, ..acc_rests])
        })

      let heads = list.reverse(heads)
      let rests = list.reverse(rests)

      let number = number_from_digits(heads)
      blocks_to_number_loop(rests, [number, ..acc])
    }
  }
}

fn parse_int_or_minus_one(str: String) {
  case int.parse(str) {
    Ok(int) -> int
    _ -> -1
  }
}

pub fn number_from_digits(digits: List(Int)) {
  let digits = cleanup_digits(digits)
  let str =
    list.map(digits, fn(d) {
      case d {
        -1 -> "0"
        d -> int.to_string(d)
      }
    })
    |> string.join("")
  let assert Ok(int) = int.parse(str)
  int
}

fn cleanup_digits(digits: List(Int)) -> List(Int) {
  digits
  |> list.drop_while(fn(d) { d == -1 })
  |> list.reverse()
  |> list.drop_while(fn(d) { d == -1 })
  |> list.reverse()
  |> list.map(fn(d) {
    case d {
      -1 -> 0
      d -> d
    }
  })
}

pub fn parse_offsets(ops_line: String) {
  let #(left_count, blocks) =
    ops_line
    |> string.to_graphemes
    |> list.fold(#(0, []), fn(acc, g) {
      let #(block_count, blocks) = acc

      case g {
        "*" -> {
          case block_count {
            0 -> #(1, blocks)
            c -> #(1, [c, ..blocks])
          }
        }
        "+" -> {
          case block_count {
            0 -> #(1, blocks)
            c -> #(1, [c, ..blocks])
          }
        }
        _ -> {
          #(block_count + 1, blocks)
        }
      }
    })

  [left_count, ..blocks]
  |> list.reverse()
}

pub fn parse_worksheet(input: String) {
  let lines = string.split(input, "\n")

  let assert Ok(num_regex) = regexp.from_string("[0-9]+")
  let parsed_arguments: List(List(Int)) =
    list.take(lines, list.length(lines) - 2)
    |> list.map(fn(l) {
      regexp.scan(num_regex, l)
      |> list.map(fn(m) {
        let assert Ok(int) = int.parse(m.content)
        int
      })
    })

  let assert [ops_line] =
    lines
    |> list.drop(list.length(lines) - 2)
    |> list.take(1)
  let parsed_ops: List(Op) =
    ops_line
    |> string.to_graphemes()
    |> list.fold([], fn(acc, g) {
      case g {
        "+" -> [Add, ..acc]
        "*" -> [Mul, ..acc]
        _ -> acc
      }
    })
    |> list.reverse()

  let assert [first, ..rest] = parsed_arguments
  let first_args = list.map(first, fn(i) { [i] })

  let arg_lists =
    rest
    |> list.fold(first_args, fn(a, b) {
      list.zip(a, b)
      |> list.map(fn(zipped) {
        let #(l, i) = zipped
        [i, ..l]
      })
    })
    |> list.map(list.reverse)

  assert list.length(arg_lists) == list.length(parsed_ops)

  let problems =
    list.zip(parsed_ops, arg_lists)
    |> list.map(fn(zipped) {
      let #(op, args) = zipped
      Problem(args, op)
    })

  Worksheet(problems)
}
