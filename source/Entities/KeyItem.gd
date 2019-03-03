extends Node

var item_name = ""
var description = ""

func initialize(item_name, description):
	self.item_name = item_name
	self.description = description

func to_dict():
	return {
		"filename": "res://Entities/KeyItem.gd",
		"item_name": self.item_name,
		"description": self.description
	}

static func from_dict(dict):
	var my_class = load("res://Scripts/Entities/KeyItem.gd")
	var to_return = my_class.new()
	to_return.initialize(dict["item_name"], dict["description"])
	return to_return