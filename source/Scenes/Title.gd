extends Node2D

var BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
var OptionsDialog = preload("res://Scenes/UI/OptionsDialog.tscn")
var OptionsSaver = preload("res://Scripts/OptionsSaver.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Battle/Monster.tscn")

func _ready():
	var tree = get_tree()
	SceneFadeManager.fade_in(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	
	var data = OptionsSaver.load()
	if data == null:
		data = {
			"zoom": Features.is_enabled("zoom-out maps"),
			"monsters_chase": Features.is_enabled("monsters chase you")
		}
	Features.set_state("zoom-out maps", data["zoom"])
	Features.set_state("monsters chase you", data["monsters_chase"])

func _on_newgame_Button_pressed():
	var tree = get_tree()
	
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	tree.change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_LoadGameButton_pressed():
	var tree = get_tree()
	
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	
	tree.change_scene("res://Scenes/LoadingScene.tscn")

func _on_Options_pressed():
	var dialog = OptionsDialog.instance()
	self.add_child(dialog)
	dialog.popup_centered()
