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
	$Locations/Exit1.set_type("Overworld")
	$Locations/Exit2.set_type("Overworld")
	
	if len(Globals.player_data.key_items) < 1:
		self.remove_child($EndGameNpc)

func get_tiles_wide():
	return $Ground.get_used_rect().size.x

func get_tiles_high():
	print("H="+str($Ground.get_used_rect().size.y))
	return $Ground.get_used_rect().size.y
