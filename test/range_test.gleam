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
