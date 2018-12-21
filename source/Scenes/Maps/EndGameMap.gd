extends Node2D

const Player = preload("res://Entities/Player.tscn")

const map_type = "Final"

func _ready():
	Globals.current_map = self
	
	var player = Player.instance()
	player.position.x = $Locations/Entrance.margin_left
	player.position.y = $Locations/Entrance.margin_top
	self.add_child(player)
	
	$Locations/Entrance.visible = false
	
	# Defunct as of October 7. TODO: send in a MapDestination.
	# But, what are the overworld target coordinates to get out?
	# Should we set those into here from GenerateWorldScene/OverworldGenerator?
	#$Locations/Exit1.initialize_from("Overworld")
	#$Locations/Exit2.initialize_from("Overworld")
	
	if len(Globals.player_data.key_items) < 1:
		self.remove_child($EndGameNpc)

func get_tiles_wide():
	return $Ground.get_used_rect().size.x

func get_tiles_high():
	return $Ground.get_used_rect().size.y
