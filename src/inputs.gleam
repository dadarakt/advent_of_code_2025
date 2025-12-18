import gleam/int
import simplifile

/// Returns the file content for a given day's input.
/// Parses the file content with the provided `parsing_fun/1`
pub fn input_for_day(day: Int, parsing_fun: fn(String) -> a) -> a {
  let filepath = "inputs/day_" <> int.to_string(day) <> ".txt"
  let assert Ok(file_content) = simplifile.read(from: filepath)
  parsing_fun(file_content)
}
