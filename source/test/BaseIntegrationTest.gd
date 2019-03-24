extends "res://addons/gut/test.gd"

func before_each():
	# Resets "Globals" to a new instance of itself
	# See: https://docs.godotengine.org/en/3.1/classes/class_gdscript.html
	Globals = load("res://Scripts/Globals.gd").new()
