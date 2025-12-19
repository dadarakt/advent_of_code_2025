import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string

import inputs
import range

pub type Ingredients {
  Ingredients(fresh: set.Set(Int), available: set.Set(Int))
}

pub fn main() {
  let ingredients = inputs.input_for_day(5, parse_ingredients)
  let fresh_ingredients = fresh_ingredients(ingredients)

  io.println(
    "There are "
    <> set.size(fresh_ingredients) |> int.to_string()
    <> " fresh ingredients",
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

pub fn fresh_ingredients(ingredients: Ingredients) -> set.Set(Int) {
  set.intersection(ingredients.available, ingredients.fresh)
}

fn parse_and_unfold_ranges(input: List(String)) -> set.Set(Int) {
  input
  |> list.flat_map(range.all_from_string)
  |> list.fold(set.new(), add_range_to_set)
}

fn add_range_to_set(set: set.Set(Int), range: range.Range) -> set.Set(Int) {
  add_range_to_set_loop(set, range.from, range.to)
}

fn add_range_to_set_loop(set: set.Set(Int), from: Int, to: Int) -> set.Set(Int) {
  case from > to {
    True -> set
    False -> {
      add_range_to_set_loop(set.insert(set, from), from + 1, to)
    }
  }
}

fn parse_ints(input: List(String)) -> set.Set(Int) {
  input
  |> list.map(int.parse)
  |> result.values
  |> set.from_list()
}
