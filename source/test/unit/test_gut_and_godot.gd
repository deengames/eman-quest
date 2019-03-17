extends "res://addons/gut/test.gd"

func test_gut_actually_works():
	assert_eq(2 + 3, 5, "addition seems broken")