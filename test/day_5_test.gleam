import day_5
import gleam/set

const test_input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32
"

pub fn parsing_test() {
  let ingredients: day_5.Ingredients = day_5.parse_ingredients(test_input)
  assert set.from_list([3, 4, 5, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    == ingredients.fresh
  assert set.from_list([1, 5, 8, 11, 17, 32]) == ingredients.available
}

pub fn fresh_test() {
  let ingredients: day_5.Ingredients = day_5.parse_ingredients(test_input)
  assert set.from_list([5, 11, 17]) == day_5.fresh_ingredients(ingredients)
}
