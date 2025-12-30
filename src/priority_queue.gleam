import gleam/list

pub type PriorityQueue(inner) {
  PriorityQueue(items: List(#(Int, inner)))
}

pub fn new() {
  let items = list.new()
  PriorityQueue(items)
}

pub fn length(priority_queue q: PriorityQueue(t)) -> Int {
  list.length(q.items)
}

pub fn to_list(priority_queue q: PriorityQueue(t)) -> List(t) {
  q.items
  |> list.map(fn(t) {
    let #(_p, i) = t
    i
  })
}

pub fn insert(
  priority_queue q: PriorityQueue(t),
  item t: t,
  priority p: Int,
) -> PriorityQueue(t) {
  let #(before_items, after_items) =
    q.items
    |> list.split_while(fn(i) {
      let #(prio, _) = i
      prio <= p
    })

  let items =
    before_items
    |> list.append([#(p, t), ..after_items])

  PriorityQueue(items)
}

pub fn pop(l: PriorityQueue(t)) -> Result(#(t, PriorityQueue(t)), Nil) {
  case l.items {
    [] -> Error(Nil)
    [first, ..rest] -> {
      let #(_, i) = first
      Ok(#(i, PriorityQueue(rest)))
    }
  }
}
