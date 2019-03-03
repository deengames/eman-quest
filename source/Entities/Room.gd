extends Node

const AreaType = preload("res://Scripts/Enums/AreaType.gd")

var grid_x
var grid_y
var connections = {} # direction => room
var area_type = AreaType.NORMAL

func _init(grid_x, grid_y):
	self.grid_x = grid_x
	self.grid_y = grid_y

func connect_to(room):
	if room.grid_x == self.grid_x:
		if room.grid_y < self.grid_y:
			# Room is above us
			self.connections["up"] = room
			room.connections["down"] = self
		else: # room is below us
			self.connections["down"] = room
			room.connections["up"] = self
	else:
		if room.grid_x < self.grid_x:
			# Room is to the left of us
			self.connections["left"] = room
			room.connections["right"] = self
		else: # room is to the right of us
			self.connections["right"] = room
			room.connections["left"] = self

func to_dict():
	# I don't know if this is correct. It only saves the current reference, not
	# the whole tree. Does it hurt reconstituting it? Area2D has persisted transitions.
	var connections = {}
	for direction in self.connections.keys():
		var node = self.connections[direction]
		# Don't recursively store connections
		connections[direction] = {
			"grid_x": node.grid_x,
			"grid_y": node.grid_y,
			"area_type": node.area_type
		}
	return {
		"grid_x": self.grid_x,
		"grid_y": self.grid_y,
		"area_type": self.area_type,
		"connections": connections
	}

static func from_dict(dict):
	var my_class = load("res://Scripts/Entities/Room.gd")
	var to_return = my_class.new(dict["grid_x"], dict["grid_y"])
	to_return.area_type = dict["area_type"]
	
	if dict.has("connections"):
		for direction in dict["connections"]:
			var obj = dict["connections"][direction]
			to_return["connections"][direction] = from_dict(obj)
		
	return to_return