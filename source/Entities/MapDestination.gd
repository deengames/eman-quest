extends Node

const DictionaryHelper = preload("res://Scripts/DictionaryHelper.gd")

# Data class
var my_position
var target_map # Vector2
var target_position # Vector2
var direction # eg. left

# Target map can be a map type (eg. Forest) or it can be a reference
# to a specific map's room (eg. forest entrance sub-area map).
func _init(my_position, target_map, target_position, direction = null):
	self.my_position = my_position
	self.target_map = target_map
	self.target_position = target_position
	self.direction = direction

func to_dict():
	return {
		"filename": "res://Entities/MapDestination.gd",
		"my_position": DictionaryHelper.vector2_to_dict(self.my_position),
		"target_map": self.target_map,
		"target_position": DictionaryHelper.vector2_to_dict(self.target_position),
		"direction": self.direction
	}

static func from_dict(dict):
	return new(
		DictionaryHelper.dict_to_vector2(dict["my_position"]),
		dict["target_map"],
		DictionaryHelper.dict_to_vector2(dict["target_position"]),
		dict["direction"]
	)