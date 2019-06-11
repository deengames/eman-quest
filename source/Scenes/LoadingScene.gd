extends Node2D

var SaveSelectWindow = preload("res://Scenes/UI/SaveSelectWindow.tscn")

func _ready():
	var window = SaveSelectWindow.instance()
	window.popup_exclusive = true
	window.disable_saving()
	add_child(window)
	window.popup_centered()
	
	