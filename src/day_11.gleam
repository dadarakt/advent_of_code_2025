import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
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

pub fn count_paths_with_visits(devices: List(Device)) {
  let adjacency_dict = build_adjacency_dict(devices)

  // example routes:
  // svr -> dac -> fft -> out == (svr -> dac) * (dac -> fft) * (fft -> out)
  // svr -> fft -> dac -> out == (svr -> fft) * (fft -> dac) * (dac --> out)
  let svr_to_dac = count_paths_loop("dac", ["svr"], adjacency_dict, 0) |> echo
  let svr_to_fft = count_paths_loop("fft", ["svr"], adjacency_dict, 0) |> echo
  let dac_to_fft = count_paths_loop("fft", ["dac"], adjacency_dict, 0) |> echo
  let fft_to_dac = count_paths_loop("dac", ["fft"], adjacency_dict, 0) |> echo
  let dac_to_out = count_paths_loop("out", ["dac"], adjacency_dict, 0) |> echo
  let fft_to_out = count_paths_loop("out", ["fft"], adjacency_dict, 0) |> echo

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
