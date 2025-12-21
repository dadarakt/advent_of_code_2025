import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string

import inputs

pub fn main() {
  let state = inputs.input_for_day(7, count_splits)

  io.println(
    "The beam will be split " <> state.splits |> int.to_string <> " times",
  )

  let tree = inputs.input_for_day(7, construct_manifold_tree)

  io.println(
    "There are " <> int.to_string(tree.permutations) <> " possible beams",
  )
}

pub type Manifold {
  Start(col: Int, permutations: Int, next: Manifold)
  Splitter(col: Int, permutations: Int, left: Manifold, right: Manifold)
  Terminal(col: Int, permutations: Int)
  Empty(col: Int, permutations: Int)
}

pub type ParseManifoldState {
  ParseManifoldState(
    beams: set.Set(Int),
    beams_to_node: dict.Dict(Int, Manifold),
  )
}

/// construct tree from bottom up
/// calculate the terminal beams, and trace them up, allowing to reference 
pub fn construct_manifold_tree(input: String) -> Manifold {
  let state = count_splits(input)

  let initial_manifolds =
    state.beams
    |> set.to_list
    |> list.map(fn(col) { #(col, Terminal(col, 1)) })
    |> dict.from_list()

  let lines = string.split(input, "\n")

  let layers =
    list.take(lines, list.length(lines) - 1)
    |> list.map(parse_manifold_line)
    |> list.map(fn(dict) {
      dict.to_list(dict)
      |> list.map(fn(t) {
        let #(_col, m) = t
        m
      })
    })
    |> list.reverse()

  let manifold_dict = construct_manifold_tree_loop(initial_manifolds, layers)
  let assert Ok(start) =
    manifold_dict
    |> dict.to_list
    |> list.map(fn(t) {
      let #(_col, m) = t
      m
    })
    |> list.find(fn(t) {
      case t {
        Start(_, _, _) -> True
        _ -> False
      }
    })

  start
}

fn construct_manifold_tree_loop(
  manifolds: dict.Dict(Int, Manifold),
  layers: List(List(Manifold)),
) {
  case layers {
    [] -> manifolds
    [current_layer, ..rest_layers] -> {
      let connected =
        current_layer
        |> list.map(fn(m) { connect_children(m, manifolds) })

      // remove now connected children and put in new nodes
      let unconnected_manifolds =
        connected
        |> list.fold(manifolds, fn(manifolds, m) {
          dict.insert(manifolds, m.col, m)
        })

      construct_manifold_tree_loop(unconnected_manifolds, rest_layers)
    }
  }
}

fn connect_children(
  manifold: Manifold,
  possible_children: dict.Dict(Int, Manifold),
) -> Manifold {
  case manifold {
    Start(start_col, _, _) -> {
      let assert Ok(child) = dict.get(possible_children, start_col)
      Start(start_col, child.permutations, child)
    }
    Splitter(split_col, _, _, _) -> {
      let assert Ok(left) = dict.get(possible_children, split_col - 1)
      let assert Ok(right) = dict.get(possible_children, split_col + 1)

      Splitter(split_col, left.permutations + right.permutations, left, right)
    }
    t -> t
  }
}

fn parse_manifold_line(line: String) -> dict.Dict(Int, Manifold) {
  line
  |> string.to_graphemes
  |> parse_manifold_line_loop(0, [])
  |> dict.from_list()
}

fn parse_manifold_line_loop(
  graphemes: List(String),
  col: Int,
  manifolds: List(#(Int, Manifold)),
) -> List(#(Int, Manifold)) {
  case graphemes {
    [] -> manifolds
    [head, ..rest] -> {
      case head {
        "S" -> {
          let manifold = #(col, Start(col, 0, Empty(col, 0)))
          parse_manifold_line_loop(rest, col + 1, [manifold, ..manifolds])
        }
        "^" -> {
          let manifold = #(
            col,
            Splitter(col, 0, Empty(col - 1, 0), Empty(col + 1, 0)),
          )
          parse_manifold_line_loop(rest, col + 1, [manifold, ..manifolds])
        }
        _ -> {
          parse_manifold_line_loop(rest, col + 1, manifolds)
        }
      }
    }
  }
}

pub type ParsingState {
  ParsingState(beams: set.Set(Int), splits: Int)
}

pub fn count_splits(str: String) {
  string.split(str, "\n")
  |> parse_split_lines
}

fn parse_split_lines(lines: List(String)) {
  parse_split_lines_loop(lines, ParsingState(set.new(), 0))
}

fn parse_split_lines_loop(lines: List(String), state: ParsingState) {
  case lines {
    [] -> state
    [head, ..rest] -> parse_split_lines_loop(rest, apply_line(head, state))
  }
}

fn apply_line(line: String, state: ParsingState) -> ParsingState {
  let graphemes = line |> string.to_graphemes()
  apply_line_loop(graphemes, 0, state)
}

fn apply_line_loop(
  graphemes: List(String),
  idx: Int,
  state: ParsingState,
) -> ParsingState {
  case graphemes {
    [] -> state
    [head, ..rest] -> {
      case head {
        "S" -> {
          let new_state =
            ParsingState(..state, beams: set.insert(state.beams, idx))
          apply_line_loop(rest, idx + 1, new_state)
        }
        "^" -> {
          case set.contains(state.beams, idx) {
            True -> {
              let new_beams =
                state.beams
                |> set.delete(idx)
                |> set.insert(idx - 1)
                |> set.insert(idx + 1)

              apply_line_loop(
                rest,
                idx + 1,
                ParsingState(new_beams, state.splits + 1),
              )
            }
            False -> {
              apply_line_loop(rest, idx + 1, state)
            }
          }
        }
        _ -> apply_line_loop(rest, idx + 1, state)
      }
    }
  }
}
