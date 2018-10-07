extends Node

const AreaType = preload("res://Scripts/Enums/AreaType.gd")

var grid_x
var grid_y
var connections = {} # direction => room
var area_type = AreaType.NORMAL

func _init(grid_x, grid_y):
	self.grid_x = grid_x
	self.grid_y = grid_y

func connect(room):
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