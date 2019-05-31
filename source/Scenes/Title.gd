extends Node2D

var BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
var OptionsDialog = preload("res://Scenes/UI/OptionsDialog.tscn")
var OptionsSaver = preload("res://Scripts/OptionsSaver.gd")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Battle/Monster.tscn")

func _ready():
	var data = OptionsSaver.load()
	if data == null:
		data = {
			"zoom": Features.is_enabled("zoom-out maps"),
			"monsters_chase": Features.is_enabled("monsters chase you")
		}
	Features.set_state("zoom-out maps", data["zoom"])
	Features.set_state("monsters chase you", data["monsters_chase"])

func _on_newgame_Button_pressed():
	get_tree().change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_LoadGameButton_pressed():
	get_tree().change_scene("res://Scenes/LoadingScene.tscn")

func _on_Options_pressed():
	var dialog = OptionsDialog.instance()
	self.add_child(dialog)
	dialog.popup_centered()
