import day_11
import gleam/list

const test_input = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out"

const test_input_part_2 = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"

pub fn parsing_test() {
  let devices = day_11.parse_devices(test_input)
  assert 10 == list.length(devices)
}

pub fn count_paths_test() {
  let devices = day_11.parse_devices(test_input)
  assert 5 == day_11.count_paths(devices)
}

pub fn count_paths_with_visits_test() {
  let devices = day_11.parse_devices(test_input_part_2)
  assert 2 == day_11.count_paths_with_visits(devices)
}
