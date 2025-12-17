import day_2

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124"

pub fn parsing_test() {
  let parsed_ranges = day_2.parse_input(test_input)
  let expected = [
    day_2.Range(11, 22),
    day_2.Range(95, 115),
    day_2.Range(998, 1012),
    day_2.Range(1_188_511_880, 1_188_511_890),
    day_2.Range(222_220, 222_224),
    day_2.Range(1_698_522, 1_698_528),
    day_2.Range(446_443, 446_449),
    day_2.Range(38_593_856, 38_593_862),
    day_2.Range(565_653, 565_659),
    day_2.Range(824_824_821, 824_824_827),
    day_2.Range(2_121_212_118, 2_121_212_124),
  ]

  assert expected == parsed_ranges
}

pub fn number_to_digits_test() {
  assert [1, 2, 3] == day_2.number_to_digits(123)
  assert [1, 2, 3] == day_2.number_to_digits(123)
  assert [1, 1, 1, 9, 9, 9] == day_2.number_to_digits(111_999)
}

pub fn duplicate_test() {
  // 1
  assert True == day_2.has_duplicate_of_length([1, 1], 1)
  assert True == day_2.has_duplicate_of_length([1, 1, 1, 1], 1)
  assert True == day_2.has_duplicate_of_length([1, 3, 2, 2], 1)
  assert False == day_2.has_duplicate_of_length([1, 2, 1], 1)
  assert False == day_2.has_duplicate_of_length([1, 2, 1], 3)
  assert False == day_2.has_duplicate_of_length([1, 2, 1], 4)

  // 2
  assert True == day_2.has_duplicate_of_length([1, 1, 1, 1], 2)
  assert True == day_2.has_duplicate_of_length([3, 8, 3, 8], 2)
  assert True == day_2.has_duplicate_of_length([1, 2, 3, 4, 3, 4, 1, 2], 2)
  assert False == day_2.has_duplicate_of_length([1, 2, 3, 3, 1, 2], 2)

  // loop
  assert True == day_2.is_valid_id(12)
  assert False == day_2.is_valid_id(22)
  assert True == day_2.is_valid_id(123_456)
  assert True == day_2.is_valid_id(1_231_213_412_145)
  assert False == day_2.is_valid_id(11)
  assert False == day_2.is_valid_id(1212)
  assert False == day_2.is_valid_id(123_456_123_456)
}

pub fn made_of_two_numbers_test() {
  assert True == day_2.made_of_two_same_numbers(11)
  assert True == day_2.made_of_two_same_numbers(22)
  assert False == day_2.made_of_two_same_numbers(13)
  assert False == day_2.made_of_two_same_numbers(134_135)
  assert True == day_2.made_of_two_same_numbers(135_135)
  assert True == day_2.made_of_two_same_numbers(123_123_123_123)
}

pub fn made_of_repeated_numbers_test() {
  assert True == day_2.made_of_repeated_numbers(121_212)
  assert False == day_2.made_of_repeated_numbers(2_121_212_118)
  assert True == day_2.made_of_repeated_numbers(38_593_859)
}

pub fn invalid_in_range_test() {
  assert [11, 22]
    == day_2.invalid_ids_in_range(
      day_2.Range(11, 22),
      day_2.made_of_two_same_numbers,
    )
  assert [99]
    == day_2.invalid_ids_in_range(
      day_2.Range(95, 115),
      day_2.made_of_two_same_numbers,
    )
  assert [1_188_511_885]
    == day_2.invalid_ids_in_range(
      day_2.Range(1_188_511_880, 1_188_511_890),
      day_2.made_of_two_same_numbers,
    )
  assert [2_121_212_121]
    == day_2.invalid_ids_in_range(
      day_2.Range(2_121_212_118, 2_121_212_124),
      day_2.made_of_repeated_numbers,
    )
  assert [11, 22]
    == day_2.invalid_ids_in_range(
      day_2.Range(11, 22),
      day_2.made_of_repeated_numbers,
    )
  assert [99, 111]
    == day_2.invalid_ids_in_range(
      day_2.Range(95, 115),
      day_2.made_of_repeated_numbers,
    )
  assert [999, 1010]
    == day_2.invalid_ids_in_range(
      day_2.Range(998, 1012),
      day_2.made_of_repeated_numbers,
    )
  assert [38_593_859]
    == day_2.invalid_ids_in_range(
      day_2.Range(38_593_856, 38_593_862),
      day_2.made_of_repeated_numbers,
    )
}
