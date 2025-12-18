import day_3
import gleam/list

const test_input = "
987654321111111
811111111111119
234234234234278
818181911112111
"

pub fn parsing_test() {
  assert [
      987_654_321_111_111,
      811_111_111_111_119,
      234_234_234_234_278,
      818_181_911_112_111,
    ]
    == day_3.parse_banks_from_string(test_input)
}

pub fn largest_joltage_test() {
  assert 98 == day_3.largest_joltage_for_bank_int(987_654_321_111_111)

  assert 89 == day_3.largest_joltage_for_bank_int(811_111_111_111_119)

  assert 78 == day_3.largest_joltage_for_bank_int(234_234_234_234_278)

  assert 92 == day_3.largest_joltage_for_bank_int(818_181_911_112_111)

  assert 29 == day_3.largest_joltage_for_bank_int(2019)

  assert 11 == day_3.largest_joltage_for_bank_int(11_111_111)

  assert 97 == day_3.largest_joltage_for_bank_int(91_111_111_117)
  assert 97 == day_3.largest_joltage_for_bank_int(191_111_111_117)

  assert 88 == day_3.largest_joltage_for_bank_int(881_111)
  assert 88 == day_3.largest_joltage_for_bank_int(8_181_111)
  assert 88 == day_3.largest_joltage_for_bank_int(811_118)
  assert 91 == day_3.largest_joltage_for_bank_int(8_111_191)

  assert 98 == day_3.largest_joltage_for_bank_int(987_654_321_111_111)
  assert 89 == day_3.largest_joltage_for_bank_int(811_111_111_111_119)
  assert 78 == day_3.largest_joltage_for_bank_int(234_234_234_234_278)
  assert 92 == day_3.largest_joltage_for_bank_int(818_181_911_112_111)
}

pub fn list_matching_exploration_test() {
  let assert [head, ..rest] = [1]
  assert [] == rest
  assert 1 == head

  let assert [head, ..rest] = [1, 2, 3]
  assert [2, 3] == rest
  assert 1 == head

  let assert [head, second, ..rest] = [1, 2]
  assert 1 == head
  assert 2 == second
  assert [] == rest

  let assert [head, second, ..rest] = [1, 2, 3]
  assert 1 == head
  assert 2 == second
  assert [3] == rest

  let assert [2] = list.drop([3, 2], 0 + 1)
}
