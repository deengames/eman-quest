extends Node

# Data class
var my_position
var target_map # Vector2
var target_position # Vector2

func _init(my_position, target_map, target_position):
	self.my_position = my_position
	self.target_map = target_map
	self.target_position = target_position

func to_dict():
	return {
		"filename": "res://Entities/MapDestination.gd",
		"my_position": [self.my_position.x, self.my_position.y],
		"target_map": self.target_map,
		"target_position": [self.target_position.x, self.target_position.y]		
	}

static func from_dict(dict):
	return new(
		Vector2(dict["my_position"][0], dict["my_position"][1]),
		dict["target_map"],
		Vector2(dict["target_position"][0], dict["target_position"][1])
	)