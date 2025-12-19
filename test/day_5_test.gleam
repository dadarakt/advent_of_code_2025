import day_5
import range

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
  assert [
      range.Range(3, 5),
      range.Range(10, 14),
      range.Range(16, 20),
      range.Range(12, 18),
    ]
    == ingredients.fresh
  assert [1, 5, 8, 11, 17, 32] == ingredients.available
}

pub fn fresh_test() {
  let ingredients: day_5.Ingredients = day_5.parse_ingredients(test_input)
  assert [5, 11, 17] == day_5.fresh_ingredients(ingredients)
}

pub fn count_fresh_test() {
  let ingredients: day_5.Ingredients = day_5.parse_ingredients(test_input)
  assert 14 == day_5.count_fresh_ingredients(ingredients)
}
