extends KinematicBody2D

const KeyItem = preload("res://Entities/KeyItem.gd")
var SceneManagement = load("res://Scripts/SceneManagement.gd")

var data = {}

const IS_BOSS = true

var x = 0
var y = 0
var is_alive = true
var data_object = null # Boss.new() instance if we're a packed scene
var key_item

# quest stuff
var events = [] setget set_events
var attach_quest_npcs = []
var replace_with_npc = null

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
	self.events = data_object.events
	self.attach_quest_npcs = data_object.attach_quest_npcs
	self.replace_with_npc = data_object.replace_with_npc
	var type = data_object.data["type"].replace(' ', '')
	$Sprite.texture = load("res://assets/images/monsters/" + type + ".png")

func set_events(value):
	events = value

func to_dict():
	return {
		"filename": "res://Entities/Battle/Boss.gd",
		"x": self.x,
		"y": self.y,
		"is_alive": self.is_alive,
		"key_item": self.key_item.to_dict(),
		"data": self.data,
		"events": self.events,
		"attach_quest_npcs": self.attach_quest_npcs,
		"replace_with_npc": self.replace_with_npc
	}

static func from_dict(dict):
	var my_class = load("res://Scripts/Entities/Boss.gd")
	var to_return = my_class.new()
	to_return.initialize(dict["x"], dict["y"], dict["data"], KeyItem.from_dict(dict["key_item"]))
	to_return.is_alive = dict["is_alive"]
	to_return.data_object = dict["data"]
	to_return.events = dict["events"]
	to_return.attach_quest_npcs = dict["attach_quest_npcs"]
	to_return.replace_with_npc = dict["replace_with_npc"]
	return to_return

func _on_Area2D_body_entered(body):
	SceneManagement.switch_to_battle_if_touched_player(get_tree(), self, body)


func _on_WiderArea2D_body_entered(body):
	if self.events != null:
		self._on_Area2D_body_entered(body)
