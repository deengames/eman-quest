extends Node

# Data class
var map_type = "" # eg. Forest
var position # Vector2

func _init(map_type, position):
	self.map_type = map_type
	self.position = position

func to_dict():
	return {
		"map_type": self.map_type,
		"x": self.position.x,
		"y": self.position.y
	}