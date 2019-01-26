extends Node2D

const Player = preload("res://Entities/Player.tscn")

### 
# A static map. Contains instructions to work + common code.
###

const map_type = "" # used in transitions, plays nice with code that looks up map_type.

func _ready():
	Globals.current_map = self
	Globals.current_map_type = self.map_type
	Globals.player = Player.instance()
	self.add_child(Globals.player)

func get_tiles_wide():
	return $Ground.get_used_rect().size.x

func get_tiles_high():
	return $Ground.get_used_rect().size.y
