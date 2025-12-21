import day_6
import gleam/string

const test_input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  
  "

pub fn parsing_test() {
  let worksheet = day_6.parse_worksheet(test_input)

  assert [
      day_6.Problem([123, 45, 6], day_6.Mul),
      day_6.Problem([328, 64, 98], day_6.Add),
      day_6.Problem([51, 387, 215], day_6.Mul),
      day_6.Problem([64, 23, 314], day_6.Add),
    ]
    == worksheet.problems
}

pub fn grand_total_test() {
  let worksheet = day_6.parse_worksheet(test_input)
  assert 4_277_556 == day_6.sum_worksheet_solutions(worksheet)
}

pub fn to_cephalopod_test() {
  let worksheet = day_6.parse_worksheet_cephalopod(test_input)
  let sum = day_6.sum_worksheet_solutions(worksheet)
  echo sum
  echo worksheet
}

pub fn parse_offsets_test() {
  assert [5, 3, 4, 3] == day_6.parse_offsets("*    +  +   *  ")
}

pub fn number_from_digits_test() {
  let digits = [3, 5, 6]
  assert 356 == day_6.number_from_digits(digits)
  let digits = [3, 5, 0]
  assert 350 == day_6.number_from_digits(digits)
}

pub fn parse_block_test() {
  assert [4, 431, 623] == day_6.blocks_to_numbers(["64 ", "23 ", "314"])
  assert [175, 581, 32] == day_6.blocks_to_numbers([" 51", "387", "215"])
  assert [8, 248, 369] == day_6.blocks_to_numbers(["328", "64 ", "98 "])
  assert [356, 24, 1] == day_6.blocks_to_numbers(["123", " 45", "  6"])
  assert [306, 4, 1] == day_6.blocks_to_numbers(["103", " 40", "  6"])
  assert [3064, 403, 1002, 1]
    == day_6.blocks_to_numbers([" 103", "  40", "   6", "1234"])
  assert [4, 3063, 2, 1401]
    == day_6.blocks_to_numbers(["103 ", "40  ", "  6 ", "1234"])

  assert [6998, 8879] == day_6.blocks_to_numbers(["86", "89", "79", "98"])
}
