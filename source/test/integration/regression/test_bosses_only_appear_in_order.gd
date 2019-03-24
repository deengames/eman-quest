extends "res://addons/gut/test.gd"

func test_gut_actually_works():
	assert_eq(1 - 3, -2, "subtraction seems broken")