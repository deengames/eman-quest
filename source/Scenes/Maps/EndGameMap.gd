extends "StaticMap.gd"

const Player = preload("res://Entities/Player.tscn")

const map_type = "Final"

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	self.add_child(player)
	
	# Show final event only if we have enough key items.
	if len(Globals.player_data.key_items) < 3:
		self.remove_child($EndGameNpc)