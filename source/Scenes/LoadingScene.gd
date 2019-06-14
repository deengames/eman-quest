extends Node2D

var SaveSelectWindow = preload("res://Scenes/UI/SaveSelectWindow.tscn")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")

func _ready():
	var window = SaveSelectWindow.instance()
	window.popup_exclusive = true
	window.disable_saving()
	add_child(window)
	window.popup_centered()
	
	var tree = get_tree()
	SceneFadeManager.fade_in(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	