import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

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

pub fn parse_worksheet(input: String) {
  let lines = string.split(input, "\n")

  let assert Ok(num_regex) = regexp.from_string("[0-9]+")
  let parsed_arguments: List(List(Int)) =
    list.take(lines, list.length(lines) - 1)
    |> list.map(fn(l) {
      regexp.scan(num_regex, l)
      |> list.map(fn(m) {
        let assert Ok(int) = int.parse(m.content)
        int
      })
    })

  let assert Ok(ops_line) = list.last(lines)
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
