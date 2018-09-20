extends Node

var is_opened = false
var contents # equipment instance
var tile_x = 0
var tile_y = 0

func _init(x, y, contents):
	self.tile_x = x
	self.tile_y = y
	self.contents = contents

func open():
	if not self.is_opened:
		self.is_opened = true
		# Grant item
		Globals.player_data.inventory.append(self.contents)