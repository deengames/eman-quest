extends "StaticMap.gd"

const map_type = 'Home'

func _ready():
	var player = Globals.player
	player.position = $Entrance.position

func show_intro_events():
	var player = Globals.player
	player.position = $Start.position