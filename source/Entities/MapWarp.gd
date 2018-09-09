extends Node2D

const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const EntranceImageXPositions = {
	"Dungeon": 0,
	"Cave": 64,
	"Forest": 128
}

# Map destination sprite
export var map_type = "" # eg. Forest

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
		SceneManagement.change_map_to(get_tree(), map_type)