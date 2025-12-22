import gleam/list
import point_3d

const test_input = "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"

import day_8

pub fn parse_points_test() {
  let points = point_3d.points_from_string(test_input)
  assert 20 == list.length(points)
}

pub fn minimal_pairwise_distance_test() {
  let points = [
    point_3d.Point3D(1, 2, 3),
    point_3d.Point3D(10, 20, 30),
    point_3d.Point3D(0, 0, 0),
    point_3d.Point3D(-5, -5, -5),
    point_3d.Point3D(100, 200, 300),
  ]
  let #(p1, p2) = day_8.minimal_pairwise_distance(points)
  assert p1 == point_3d.Point3D(1, 2, 3)
  assert p2 == point_3d.Point3D(0, 0, 0)
}

pub fn closest_circuits_test() {
  let circuits = day_8.parse_circuits(test_input)
  assert Ok(#(
      day_8.Circuit([point_3d.Point3D(162, 817, 812)]),
      day_8.Circuit([point_3d.Point3D(425, 690, 689)]),
    ))
    == day_8.find_closest_circuits(circuits)
}

pub fn equality_test() {
  let a = day_8.Circuit([point_3d.Point3D(1, 2, 3)])
  let b = day_8.Circuit([point_3d.Point3D(1, 2, 3)])

  assert a == b
}

pub fn merge_circuits_test() {
  let a = day_8.Circuit([point_3d.Point3D(1, 2, 3)])
  let b = day_8.Circuit([point_3d.Point3D(2, 3, 5), point_3d.Point3D(8, 7, 6)])

  assert day_8.Circuit([
      point_3d.Point3D(1, 2, 3),
      point_3d.Point3D(2, 3, 5),
      point_3d.Point3D(8, 7, 6),
    ])
    == day_8.merge_circuits(a, b)
}

pub fn connect_closest_circuits_test() {
  let circuits = day_8.parse_circuits(test_input)
  day_8.connect_closest_circuits(circuits, 10, 0.0)
  |> list.map(fn(c) { list.length(c.junction_boxes) })
}

pub fn closest_circuits_by_boxes_test() {
  let circuits = day_8.parse_circuits(test_input)
  day_8.find_closest_junction_boxes(circuits, 0.0)
}

pub fn iterative_merging_test() {
  let circuits = day_8.parse_circuits(test_input)
  echo day_8.merge_until(circuits, 1)
}
