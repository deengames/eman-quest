extends Node2D

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	SceneManagement.change_map_to(get_tree(), "Overworld")