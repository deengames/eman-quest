extends Node2D

var SaveManager = preload("res://Scripts/SaveManager.gd")

func _ready():
	# Wait just long enough for the scene to display, then generate
	yield(get_tree().create_timer(0.25), 'timeout')
	SaveManager.load("test", get_tree())