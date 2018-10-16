extends KinematicBody2D

const KeyItem = preload("res://Entities/KeyItem.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

var data = {}

const IS_BOSS = true

var x = 0
var y = 0
var is_alive = true
var data_object = null # Boss.new() instance if we're a packed scene
var key_item

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func initialize(x, y, data, key_item):
	self.x = x
	self.y = y
	self.data = data
	self.key_item = key_item

func initialize_from(data_object):
	self.data_object = data_object
	self.position.x = data_object.x
	self.position.y = data_object.y
	self.key_item = data_object.key_item
	
func to_dict():
	return {
		"filename": "res://Entities/Battle/Boss.gd",
		"x": self.x,
		"y": self.y,
		"is_alive": self.is_alive,
		"key_item": self.key_item.to_dict(),
		"data": self.data
	}

static func from_dict(dict):
	var to_return = new()
	to_return.initialize(dict["x"], dict["y"], KeyItem.from_dict(dict["key_item"]))
	to_return.is_alive = dict["is_alive"]
	to_return.data_object = dict["data"]
	return to_return

func _on_Area2D_body_entered(body):
	SceneManagement.switch_to_battle_if_touched_player(self, body)
