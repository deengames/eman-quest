extends "StaticMap.gd"

const map_type = 'Home'

func show_intro_events():
	var player = Globals.player
	player.position.x = $Start.position.x
	player.position.y = $Start.position.y