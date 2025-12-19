import day_6

const test_input = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  "

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
