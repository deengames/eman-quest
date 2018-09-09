extends Node2D

# Map destination sprite
export var map_type = "" # eg. Forest

var SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_type(map_type):
	self.map_type = map_type
	$Sprite.visible = true
	
	if map_type == "Forest":
		$Sprite.region_rect.position.x = 128
	elif map_type == "Cave":
		$Sprite.region_rect.position.x = 64
	elif map_type == "Dungeon":
		$Sprite.region_rect.position.x = 0
	else:
		# Not sure what this is. Prolly transition from map => world
		$Sprite.visible = false

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		SceneManagement.change_map_to(get_tree(), map_type)