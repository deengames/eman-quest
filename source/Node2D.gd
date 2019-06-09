extends Node2D

const SaveSelectWindow = preload("res://Scenes/UI/SaveSelectWindow.tscn")

func _ready():
	var instance = SaveSelectWindow.instance()
	add_child(instance)
	instance.popup_centered()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
