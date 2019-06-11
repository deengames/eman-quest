extends Node2D

var SaveManager = preload("res://Scripts/SaveManager.gd")
var SaveSelectWindow = preload("res://Scenes/UI/SaveSelectWindow.tscn")

func _ready():
	var window = SaveSelectWindow.instance()
	window.disable_saving()
	add_child(window)
	window.popup_centered()
	
	window.connect("on_load", self, "_load_game")
	
func _load_game(save_id):
	# Wait just long enough for the scene to display, then generate
	yield(get_tree().create_timer(0.25), 'timeout')
	SaveManager.load("save" + str(save_id), get_tree())