import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

import inputs

pub type Device {
  Device(id: String, connections: List(String))
}

pub fn main() {
  let devices = inputs.input_for_day(11, parse_devices)
  let assert Ok(start) = find_start_device(devices)
  let assert Ok(target) = find_target_device(devices)
  let adjacency_dict = build_adjacency_dict(devices)

  let paths = find_paths(adjacency_dict, start, target)

  io.println("There are " <> list.length(paths) |> int.to_string <> " paths.")
}

pub fn find_paths(
  adjacency_dict: Dict(String, List(String)),
  start: Device,
  target: Device,
) {
  todo
}

pub fn build_adjacency_dict(devices: List(Device)) {
  devices
  |> list.fold(dict.new(), fn(acc, d) { dict.insert(acc, d.id, d.connections) })
}

fn find_start_device(devices: List(Device)) -> Result(Device, Nil) {
  devices
  |> list.find(fn(d) { d.id == "you" })
}

fn find_target_device(devices: List(Device)) {
  devices
  |> list.find(fn(d) { d.id == "out" })
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
