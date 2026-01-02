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

pub fn main() {
  let devices = inputs.input_for_day(11, parse_devices)
  let paths = count_paths(devices)

  io.println("There are " <> int.to_string(paths) <> " paths.")
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
