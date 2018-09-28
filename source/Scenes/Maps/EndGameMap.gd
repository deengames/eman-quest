extends Node2D

const Player = preload("res://Entities/Player.tscn")

const ENTRANCE_COORDINATES_IN_TILES = [7, 7]
const map_type = "Final"

func _ready():
	Globals.current_map = self
	
	var player = Player.instance()
	player.position.x = self.ENTRANCE_COORDINATES_IN_TILES[0] * Globals.TILE_WIDTH
	player.position.y = self.ENTRANCE_COORDINATES_IN_TILES[1] * Globals.TILE_HEIGHT
	
	self.add_child(player)