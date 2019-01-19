extends "StaticMap.gd"

const Player = preload("res://Entities/Player.tscn")

const map_type = "Final"

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	self.add_child(player)
	
	if Globals.bosses_defeated >= 3:
		$Umayyah.visible = true