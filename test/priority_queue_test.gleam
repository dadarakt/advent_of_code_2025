import priority_queue.{type PriorityQueue}

pub fn init_test() {
  let q: PriorityQueue(i) = priority_queue.new()
  assert 0 == priority_queue.length(q)
}

pub fn insert_test() {
  let q =
    priority_queue.new()
    |> priority_queue.insert("a", 3)
    |> priority_queue.insert("b", 2)
    |> priority_queue.insert("c", 1)

  assert ["c", "b", "a"] == priority_queue.to_list(q)
}

pub fn pop_test() {
  let q =
    priority_queue.new()
    |> priority_queue.insert("a", 3)
    |> priority_queue.insert("b", 2)
    |> priority_queue.insert("c", 1)

  let assert Ok(#(popped, rest)) = priority_queue.pop(q)

  assert popped == "c"
  assert rest.items == [#(2, "b"), #(3, "a")]

  let q = priority_queue.new()
  let assert Error(Nil) = priority_queue.pop(q)
}
