extends Node2D

const map_type = 'Home'

func _ready():
	Globals.current_map = self

func get_tiles_wide():
	return $Ground.get_used_rect().size.x

func get_tiles_high():
	return $Ground.get_used_rect().size.y

func show_intro_events():
	var player = Globals.player
	var position = $Start.position
	player.position.x = position.x
	player.position.y = position.y