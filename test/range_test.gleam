import range

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124"

pub fn all_from_string_test() {
  let parsed_ranges = range.all_from_string(test_input)
  let expected = [
    range.Range(11, 22),
    range.Range(95, 115),
    range.Range(998, 1012),
    range.Range(1_188_511_880, 1_188_511_890),
    range.Range(222_220, 222_224),
    range.Range(1_698_522, 1_698_528),
    range.Range(446_443, 446_449),
    range.Range(38_593_856, 38_593_862),
    range.Range(565_653, 565_659),
    range.Range(824_824_821, 824_824_827),
    range.Range(2_121_212_118, 2_121_212_124),
  ]

  assert expected == parsed_ranges
}

pub fn from_string_test() {
  assert range.Range(0, 1) == range.from_string("0-1")
  assert range.Range(102_010, 111_111) == range.from_string("102010-111111")
}

pub fn enumerate_test() {
  assert [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    == range.enumerate(range.Range(0, 10))
  assert [1] == range.enumerate(range.Range(1, 1))
}

pub fn in_range_test() {
  assert False == range.in_range(range.Range(0, 10), -5)
  assert True == range.in_range(range.Range(0, 10), 0)
  assert True == range.in_range(range.Range(0, 10), 5)
  assert True == range.in_range(range.Range(0, 10), 10)
  assert False == range.in_range(range.Range(0, 10), 15)
}

pub fn merge_test() {
  assert Ok(range.Range(0, 10))
    == range.try_merge(range.Range(0, 10), range.Range(0, 10))
  assert Ok(range.Range(0, 10))
    == range.try_merge(range.Range(0, 10), range.Range(0, 5))
  assert Ok(range.Range(0, 10))
    == range.try_merge(range.Range(0, 5), range.Range(0, 10))
  assert Ok(range.Range(1, 10))
    == range.try_merge(range.Range(1, 5), range.Range(6, 10))
  assert Error(Nil) == range.try_merge(range.Range(1, 3), range.Range(6, 10))
  assert Ok(range.Range(1, 10))
    == range.try_merge(range.Range(1, 10), range.Range(2, 5))
  assert Ok(range.Range(1, 10))
    == range.try_merge(range.Range(1, 10), range.Range(2, 10))
  assert Ok(range.Range(1, 12))
    == range.try_merge(range.Range(1, 10), range.Range(2, 12))
}

pub fn merge_ranges_test() {
  assert [] == range.merge_ranges([])
  assert [range.Range(0, 1)] == range.merge_ranges([range.Range(0, 1)])
  assert [range.Range(0, 10)]
    == range.merge_ranges([
      range.Range(1, 5),
      range.Range(4, 10),
      range.Range(0, 3),
    ])
}

pub fn overlap_test() {
  assert False == range.are_disjoint(range.Range(10, 14), range.Range(12, 20))
  assert True
    == range.are_disjoint(
      range.Range(123_733_999_511_819, 129_097_742_451_553),
      range.Range(72_457_259_933_919, 73_006_486_209_179),
    )

  assert False
    == range.are_disjoint(
      range.Range(447_751_758_628_882, 448_426_894_178_436),
      range.Range(447_751_758_628_882, 447_890_076_574_460),
    )
}
