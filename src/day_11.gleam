import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

import inputs

pub type Device {
  Device(id: String, connections: List(String))
}

pub type ConnectionState {
  ConnectionState(current_node: String, visited_dac: Bool, visited_fft: Bool)
}

pub fn main() {
  let devices = inputs.input_for_day(11, parse_devices)
  let paths = count_paths(devices)

  io.println("There are " <> int.to_string(paths) <> " paths from you to out")

  let visited_paths = count_paths_with_visits(devices)

  io.println(
    "There are "
    <> int.to_string(visited_paths)
    <> " paths from svr to out visiting dac and fft",
  )
}

pub fn subgraph(
  adjacency_dict: Dict(String, List(String)),
  topological_order: List(String),
  from: String,
  to: String,
) {
  let subgraph_nodes =
    topological_order
    |> list.drop_while(fn(n) { n != from })
    |> list.take_while(fn(n) { n != to })

  adjacency_dict
  |> dict.take(subgraph_nodes)
}

pub fn build_topological_order(adjacency_dict: Dict(String, List(String))) {
  //let adjacency_dict = build_adjacency_dict(devices)
  let initial_edge_dict =
    adjacency_dict
    |> dict.keys
    |> list.fold(dict.new(), fn(edge_dict, d) {
      dict.insert(edge_dict, d, set.new())
    })

  let incoming_edge_dict: Dict(String, Set(String)) =
    adjacency_dict
    |> dict.to_list
    |> list.fold(initial_edge_dict, fn(edge_dict, t) {
      let #(n, edges) = t
      edges
      |> list.fold(edge_dict, fn(edge_dict, c) {
        let s =
          dict.get(edge_dict, c)
          |> result.unwrap(set.new())
          |> set.insert(n)

        dict.insert(edge_dict, c, s)
      })
    })

  let no_incoming_edges =
    incoming_edge_dict
    |> dict.to_list
    |> list.filter_map(fn(t) {
      let #(k, v) = t
      case set.is_empty(v) {
        True -> Ok(k)
        _ -> Error(Nil)
      }
    })

  topo_loop(no_incoming_edges, [], adjacency_dict, incoming_edge_dict)
}

fn topo_loop(s, l, adjacency_dict, edge_dict) {
  case s {
    [] -> {
      case dict.values(edge_dict) |> list.all(set.is_empty) {
        True -> Ok(list.reverse(l))
        False -> Error("There is a loop in the graph")
      }
    }
    [n, ..rest] -> {
      let new_l = [n, ..l]
      let #(new_edge_dict, new_s) =
        adjacency_dict
        |> dict.get(n)
        |> result.unwrap([])
        |> list.fold(#(edge_dict, rest), fn(t, m) {
          let #(edge_dict, s) = t
          let incoming =
            edge_dict
            |> dict.get(m)
            |> result.unwrap(set.new())
            |> set.delete(n)
          case set.is_empty(incoming) {
            True -> #(edge_dict |> dict.delete(m), [m, ..s])
            False -> #(dict.insert(edge_dict, m, incoming), s)
          }
        })
      topo_loop(new_s, new_l, adjacency_dict, new_edge_dict)
    }
  }
}

pub fn count_paths_with_visits(devices: List(Device)) {
  let adjacency_dict = build_adjacency_dict(devices)
  let assert Ok(topological_order) = build_topological_order(adjacency_dict)
  echo topological_order
  echo "-----------------------------------------------"

  // example routes:
  // svr -> dac -> fft -> out == (svr -> dac) * (dac -> fft) * (fft -> out)
  // svr -> fft -> dac -> out == (svr -> fft) * (fft -> dac) * (dac --> out)
  let g_svr_to_dac = subgraph(adjacency_dict, topological_order, "svr", "dac")
  let g_svr_to_fft = subgraph(adjacency_dict, topological_order, "svr", "fft")
  let g_dac_to_fft = subgraph(adjacency_dict, topological_order, "dac", "fft")
  let g_fft_to_dac = subgraph(adjacency_dict, topological_order, "fft", "dac")
  let g_dac_to_out = subgraph(adjacency_dict, topological_order, "dac", "out")
  let g_fft_to_out = subgraph(adjacency_dict, topological_order, "fft", "out")
  echo "============="
  echo adjacency_dict |> dict.size
  echo g_svr_to_dac |> dict.size
  echo g_svr_to_fft |> dict.size
  echo g_dac_to_fft |> dict.size
  echo g_fft_to_dac |> dict.size
  echo g_dac_to_out |> dict.size
  echo g_fft_to_out |> dict.size
  echo "============="

  let svr_to_dac = count_paths_loop("dac", ["svr"], g_svr_to_dac, 0)
  echo "~~~~~~~~~~~~~"
  let svr_to_fft = count_paths_loop("fft", ["svr"], g_svr_to_fft, 0)
  echo "~~~~~~~~~~~~~"
  let dac_to_fft = count_paths_loop("fft", ["dac"], g_dac_to_fft, 0)
  echo "~~~~~~~~~~~~~"
  let fft_to_dac = count_paths_loop("dac", ["fft"], g_fft_to_dac, 0)
  echo "~~~~~~~~~~~~~"
  let dac_to_out = count_paths_loop("out", ["dac"], g_dac_to_out, 0)
  echo "~~~~~~~~~~~~~"
  let fft_to_out = count_paths_loop("out", ["fft"], g_fft_to_out, 0)
  echo "~~~~~~~~~~~~~"

  svr_to_dac * dac_to_fft * fft_to_out + svr_to_fft * fft_to_dac * dac_to_out
}

pub fn count_paths_with_visits_loop(
  node: String,
  seen_fft: Bool,
  seen_dac: Bool,
  adjacency_dict: Dict(String, List(String)),
) {
  case node {
    "out" -> {
      case seen_fft && seen_dac {
        True -> 1
        False -> 0
      }
    }
    "dac" -> {
      dict.get(adjacency_dict, node)
      |> result.unwrap([])
      |> list.fold(0, fn(acc, n) {
        acc + count_paths_with_visits_loop(n, seen_fft, True, adjacency_dict)
      })
    }

    "fft" -> {
      dict.get(adjacency_dict, node)
      |> result.unwrap([])
      |> list.fold(0, fn(acc, n) {
        acc + count_paths_with_visits_loop(n, True, seen_dac, adjacency_dict)
      })
    }
    _ -> {
      dict.get(adjacency_dict, node)
      |> result.unwrap([])
      |> list.fold(0, fn(acc, n) {
        acc
        + count_paths_with_visits_loop(n, seen_fft, seen_dac, adjacency_dict)
      })
    }
  }
}

pub fn count_paths(devices: List(Device)) {
  let start_device = find_device(devices, "you")
  let adjacency_dict = build_adjacency_dict(devices)
  count_paths_loop("out", [start_device.id], adjacency_dict, 0)
}

pub fn count_paths_loop(
  target: String,
  open_nodes: List(String),
  adjacency_dict: Dict(String, List(String)),
  path_count: Int,
) {
  case open_nodes {
    [] -> path_count
    [first, ..rest] -> {
      case first == target {
        True -> {
          count_paths_loop(target, rest, adjacency_dict, path_count + 1)
        }
        False -> {
          let new_open_nodes =
            list.append(
              rest,
              dict.get(adjacency_dict, first) |> result.unwrap([]),
            )
          count_paths_loop(target, new_open_nodes, adjacency_dict, path_count)
        }
      }
    }
  }
}

pub fn build_adjacency_dict(devices: List(Device)) {
  devices
  |> list.fold(dict.new(), fn(acc, d) { dict.insert(acc, d.id, d.connections) })
}

fn find_device(devices: List(Device), id: String) -> Device {
  let assert Ok(device) =
    devices
    |> list.find(fn(d) { d.id == id })

  device
}

pub fn parse_devices(str: String) {
  string.split(str, "\n")
  |> list.filter(fn(l) { !string.is_empty(l) })
  |> list.map(fn(l) {
    let assert [id, conn_strings] = string.split(l, ":")

    let connections =
      string.split(conn_strings, " ")
      |> list.map(string.trim)
      |> list.filter(fn(s) { !string.is_empty(s) })

    Device(id: id, connections: connections)
  })
}
