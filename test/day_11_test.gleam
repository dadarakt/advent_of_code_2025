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

pub fn parsing_test() {
  let devices = day_11.parse_devices(test_input)
  echo devices
  assert 10 == list.length(devices)
}
