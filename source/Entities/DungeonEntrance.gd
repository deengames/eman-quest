extends Node2D

export var map_type = "" # eg. Forest

var SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		SceneManagement.change_map_to(get_tree(), map_type)