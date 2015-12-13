module softwareevolution::series2::tests::Assertions

public void assertEquals(value actual, value expected) {
  assert expected == actual : "Expected <expected>, but got <actual>";
}

public void assertIn(value v, set[value] values) {
  assert v in values : "Expected <v> in <values>";
}

public void assertIn(value v, list[value] values) {
  assert v in values : "Expected <v> in <values>";
}