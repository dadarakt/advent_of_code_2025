import day_4
import gleam/int

const test_input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

const matrix = [
  ["a_0", "a_1", "a_2", "a_3"],
  ["b_0", "b_1", "b_2", "b_3"],
  ["c_0", "c_1", "c_2", "c_3"],
  ["d_0", "d_1", "d_2", "d_3"],
]

pub fn parsing_test() {
  let expected = [
    [0, 0, 1, 1, 0, 1, 1, 1, 1, 0],
    [1, 1, 1, 0, 1, 0, 1, 0, 1, 1],
    [1, 1, 1, 1, 1, 0, 1, 0, 1, 1],
    [1, 0, 1, 1, 1, 1, 0, 0, 1, 0],
    [1, 1, 0, 1, 1, 1, 1, 0, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 0, 1],
    [0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
    [1, 0, 1, 1, 1, 0, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 0, 1, 0, 1, 1, 1, 0, 1, 0],
  ]
  assert expected == day_4.parse_rolls(test_input)
}

pub fn sub_matrix_test() {
  assert [["a_0", "a_1", "a_2", "a_3"]]
    == day_4.sub_matrix(matrix, #(0, 0), #(0, 3))
  assert [["d_0", "d_1", "d_2", "d_3"]]
    == day_4.sub_matrix(matrix, #(3, 3), #(0, 3))
  assert [["a_0"], ["b_0"], ["c_0"], ["d_0"]]
    == day_4.sub_matrix(matrix, #(0, 3), #(0, 0))
  assert [["a_3"], ["b_3"], ["c_3"], ["d_3"]]
    == day_4.sub_matrix(matrix, #(0, 3), #(3, 3))
  assert [["b_1", "b_2"], ["c_1", "c_2"]]
    == day_4.sub_matrix(matrix, #(1, 2), #(1, 2))

  // out of bounds cases
  assert [["a_0", "a_1"], ["b_0", "b_1"]]
    == day_4.sub_matrix(matrix, #(-1, 1), #(-1, 1))

  assert [["c_2", "c_3"], ["d_2", "d_3"]]
    == day_4.sub_matrix(matrix, #(2, 4), #(2, 4))
}

pub fn sum_matrix_test() {
  assert 0 == day_4.sum_matrix([[]], int.add)
  assert 0 == day_4.sum_matrix([[0]], int.add)
  assert 1 == day_4.sum_matrix([[1]], int.add)
  assert 10 == day_4.sum_matrix([[1, 2, 3, 4]], int.add)
  assert 10 == day_4.sum_matrix([[], [1, 2, 3, 4]], int.add)
  assert 10 == day_4.sum_matrix([[0], [1, 2, 3, 4]], int.add)
  assert 20 == day_4.sum_matrix([[1, 2, 3, 4], [1, 2, 3, 4]], int.add)
}

pub fn count_rolls_test() {
  let rolls = day_4.parse_rolls(test_input)
  assert 13 == day_4.count_removable_rolls(rolls)
}

pub fn update_matrix_test() {
  assert [
      ["hurray", "a_1", "a_2", "a_3"],
      ["b_0", "b_1", "b_2", "b_3"],
      ["c_0", "c_1", "c_2", "c_3"],
      ["d_0", "d_1", "d_2", "d_3"],
    ]
    == day_4.update_matrix(matrix, #(0, 0), "hurray")

  assert [
      ["a_0", "a_1", "a_2", "a_3"],
      ["b_0", "b_1", "b_2", "b_3"],
      ["c_0", "c_1", "c_2", "c_3"],
      ["d_0", "d_1", "d_2", "hurray"],
    ]
    == day_4.update_matrix(matrix, #(3, 3), "hurray")

  assert [
      ["a_0", "a_1", "a_2", "a_3"],
      ["b_0", "b_1", "hurray", "b_3"],
      ["c_0", "c_1", "c_2", "c_3"],
      ["d_0", "d_1", "d_2", "d_3"],
    ]
    == day_4.update_matrix(matrix, #(1, 2), "hurray")
}
