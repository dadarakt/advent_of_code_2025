import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import inputs

const target = "out"

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
  let start_device = find_device(devices, "svr")
  let adjacency_dict = build_adjacency_dict(devices)
  count_paths_with_visits_loop(
    [ConnectionState(start_device.id, False, False)],
    adjacency_dict,
    0,
  )
}

pub fn count_paths_with_visits_loop(
  open_nodes: List(ConnectionState),
  adjacency_dict: Dict(String, List(String)),
  path_count: Int,
) {
  case open_nodes {
    [] -> path_count
    [first, ..rest] -> {
      case first.current_node {
        "out" -> {
          case first.visited_dac && first.visited_fft {
            True ->
              count_paths_with_visits_loop(rest, adjacency_dict, path_count + 1)
            False ->
              count_paths_with_visits_loop(rest, adjacency_dict, path_count)
          }
        }
        "dac" -> {
          let next_states =
            dict.get(adjacency_dict, first.current_node)
            |> result.unwrap([])
            |> list.map(fn(id) {
              ConnectionState(..first, current_node: id, visited_dac: True)
            })
          count_paths_with_visits_loop(
            list.append(rest, next_states),
            adjacency_dict,
            path_count,
          )
        }

        "fft" -> {
          let next_states =
            dict.get(adjacency_dict, first.current_node)
            |> result.unwrap([])
            |> list.map(fn(id) {
              ConnectionState(..first, current_node: id, visited_fft: True)
            })
          count_paths_with_visits_loop(next_states, adjacency_dict, path_count)
        }
        _ -> {
          let next_states =
            dict.get(adjacency_dict, first.current_node)
            |> result.unwrap([])
            |> list.map(fn(id) { ConnectionState(..first, current_node: id) })
          count_paths_with_visits_loop(
            list.append(rest, next_states),
            adjacency_dict,
            path_count,
          )
        }
      }
    }
  }
}

pub fn count_paths(devices: List(Device)) {
  let start_device = find_start_device(devices)
  let adjacency_dict = build_adjacency_dict(devices)
  count_paths_loop([start_device.id], adjacency_dict, 0)
}

pub fn count_paths_loop(
  open_nodes: List(String),
  adjacency_dict: Dict(String, List(String)),
  path_count: Int,
) {
  case open_nodes {
    [] -> path_count
    [first, ..rest] -> {
      case first == target {
        True -> {
          count_paths_loop(rest, adjacency_dict, path_count + 1)
        }
        False -> {
          let new_open_nodes =
            list.append(
              rest,
              dict.get(adjacency_dict, first) |> result.unwrap([]),
            )
          count_paths_loop(new_open_nodes, adjacency_dict, path_count)
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

fn find_start_device(devices: List(Device)) -> Device {
  let assert Ok(start_device) =
    devices
    |> list.find(fn(d) { d.id == "you" })

  start_device
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
