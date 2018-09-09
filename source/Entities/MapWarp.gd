extends Node2D

const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const EntranceImageXPositions = {
	"Dungeon": 0,
	"Cave": 64,
	"Forest": 128
}

# Map destination sprite
var map_type = "" # eg. Forest

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_type(map_type):
	self.map_type = map_type
	$Sprite.visible = true
	
	if map_type in EntranceImageXPositions.keys():
		$Sprite.region_rect.position.x = EntranceImageXPositions[map_type]
	else:
		# Not sure what this is. Prolly transition from map => world
		$Sprite.visible = false

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		# Leaving overworld? Come back one tile under the current tile.
		if Globals.current_map.map_type == "Overworld":
			Globals.overworld_position = Vector2(self.position.x, self.position.y + Globals.TILE_HEIGHT)
			
		SceneManagement.change_map_to(get_tree(), map_type)
		
		# Come back to the overworld? Restore coordinates.
		if Globals.current_map.map_type == "Overworld" and Globals.overworld_position != null:
			Globals.player.position = Globals.overworld_position
			Globals.overworld_position = null