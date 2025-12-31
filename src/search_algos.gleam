import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import priority_queue.{type PriorityQueue}

pub fn a_star_search(
  start: s,
  goal: s,
  h: fn(s) -> Int,
  next: fn(s) -> List(s),
) -> Result(List(s), String) {
  a_star_loop(
    goal,
    h,
    next,
    priority_queue.new() |> priority_queue.insert(start, h(start)),
    dict.new() |> dict.insert(start, h(start)),
    dict.new() |> dict.insert(start, 0),
    dict.new(),
  )
}

fn a_star_loop(
  goal: s,
  h: fn(s) -> Int,
  next: fn(s) -> List(s),
  open_queue: PriorityQueue(s),
  f_scores: Dict(s, Int),
  g_scores: Dict(s, Int),
  came_from: Dict(s, s),
) -> Result(List(s), String) {
  case priority_queue.is_empty(open_queue) {
    True -> Error("no solution found")
    False -> {
      let assert Ok(#(state, rest)) = priority_queue.pop(open_queue)
      case state == goal {
        True -> Ok(trace_back_path(state, came_from))
        False -> {
          let assert Ok(curr_g) = dict.get(g_scores, state)
          let new_states = next(state)

          let #(g_scores, f_scores, came_from, open_queue) =
            new_states
            |> list.fold(#(g_scores, f_scores, came_from, rest), fn(scores, s) {
              let #(g_scores, f_scores, came_from, open_queue) = scores
              let cur_g = dict.get(g_scores, s) |> result.unwrap(1_000_000_000)
              // TODO hardcoded dist measure
              let new_g = curr_g + 1

              case new_g < cur_g {
                True -> {
                  let f_score = new_g + h(s)
                  let updated_queue = case
                    priority_queue.contains(open_queue, s)
                  {
                    True -> open_queue
                    False -> open_queue |> priority_queue.insert(s, f_score)
                  }
                  #(
                    g_scores |> dict.insert(s, new_g),
                    f_scores |> dict.insert(s, f_score),
                    came_from |> dict.insert(s, state),
                    updated_queue,
                  )
                }
                False -> {
                  #(g_scores, f_scores, came_from, open_queue)
                }
              }
            })
          a_star_loop(goal, h, next, open_queue, f_scores, g_scores, came_from)
        }
      }
    }
  }
}

fn trace_back_path(s: s, came_from: Dict(s, s)) -> List(s) {
  trace_back_path_loop(s, came_from, [])
}

fn trace_back_path_loop(s, came_from, acc) {
  case dict.get(came_from, s) {
    Error(_) -> acc
    Ok(new_s) -> trace_back_path_loop(new_s, came_from, [s, ..acc])
  }
}

pub fn breadth_first_solve(
  queue: List(s),
  next_states_fun: fn(s) -> List(s),
  eval_fun: fn(s) -> Bool,
  hash_state_fun: fn(s) -> Int,
  seen_state_hashes: Set(Int),
) -> Result(s, String) {
  case queue {
    [] -> Error("No Solution possible")
    [state, ..rest] -> {
      case eval_fun(state) {
        True -> Ok(state)
        False -> {
          let #(seen_hashes, new_states) =
            next_states_fun(state)
            |> list.fold(#(seen_state_hashes, []), fn(acc, s) {
              let #(hashes, states) = acc
              let hash = hash_state_fun(s)

              case set.contains(hashes, hash) {
                True -> #(hashes, states)
                False -> #(set.insert(hashes, hash), [s, ..states])
              }
            })

          let updated_queue = list.append(rest, new_states)

          breadth_first_solve(
            updated_queue,
            next_states_fun,
            eval_fun,
            hash_state_fun,
            seen_hashes,
          )
        }
      }
    }
  }
}
