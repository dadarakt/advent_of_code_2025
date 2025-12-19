import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import inputs
import range

pub type Ingredients {
  Ingredients(fresh: List(range.Range), available: List(Int))
}

pub fn main() {
  let ingredients = inputs.input_for_day(5, parse_ingredients)
  let fresh_ingredients = fresh_ingredients(ingredients)

  io.println(
    "There are "
    <> list.length(fresh_ingredients) |> int.to_string()
    <> " fresh ingredients among the available",
  )

  let count = count_fresh_ingredients(ingredients)
  io.println(
    "There are " <> count |> int.to_string() <> " possible fresh ingredients",
  )
  Nil
}

pub fn parse_ingredients(input: String) -> Ingredients {
  let #(fresh_ranges, available) =
    input
    |> string.split("\n")
    |> list.split_while(fn(l) { l != "" })

  Ingredients(parse_and_unfold_ranges(fresh_ranges), parse_ints(available))
}

pub fn fresh_ingredients(ingredients: Ingredients) -> List(Int) {
  ingredients.available
  |> list.filter(fn(i) {
    ingredients.fresh |> list.any(fn(r) { range.in_range(r, i) })
  })
}

pub fn count_fresh_ingredients(ingredients: Ingredients) -> Int {
  let merged_ranges = ingredients.fresh |> range.merge_until_no_overlap()
  assert all_disjoint(merged_ranges)

  merged_ranges
  |> list.fold(0, fn(acc, r) { acc + range.size(r) })
}

fn all_disjoint(ranges: List(range.Range)) -> Bool {
  list.combination_pairs(ranges)
  list.window_by_2(ranges)
  |> list.all(fn(t) {
    let #(a, b) = t
    range.are_disjoint(a, b)
  })
}

fn parse_and_unfold_ranges(input: List(String)) -> List(range.Range) {
  input
  |> list.flat_map(range.all_from_string)
}

fn parse_ints(input: List(String)) -> List(Int) {
  input
  |> list.map(int.parse)
  |> result.values
}
