import day_2
import range

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
      range.Range(11, 22),
      day_2.made_of_two_same_numbers,
    )
  assert [99]
    == day_2.invalid_ids_in_range(
      range.Range(95, 115),
      day_2.made_of_two_same_numbers,
    )
  assert [1_188_511_885]
    == day_2.invalid_ids_in_range(
      range.Range(1_188_511_880, 1_188_511_890),
      day_2.made_of_two_same_numbers,
    )
  assert [2_121_212_121]
    == day_2.invalid_ids_in_range(
      range.Range(2_121_212_118, 2_121_212_124),
      day_2.made_of_repeated_numbers,
    )
  assert [11, 22]
    == day_2.invalid_ids_in_range(
      range.Range(11, 22),
      day_2.made_of_repeated_numbers,
    )
  assert [99, 111]
    == day_2.invalid_ids_in_range(
      range.Range(95, 115),
      day_2.made_of_repeated_numbers,
    )
  assert [999, 1010]
    == day_2.invalid_ids_in_range(
      range.Range(998, 1012),
      day_2.made_of_repeated_numbers,
    )
  assert [38_593_859]
    == day_2.invalid_ids_in_range(
      range.Range(38_593_856, 38_593_862),
      day_2.made_of_repeated_numbers,
    )
}
