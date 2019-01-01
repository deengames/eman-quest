extends Node2D

var AudioManager = preload("res://Scripts/AudioManager.gd")
var BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
var OptionsDialog = preload("res://Scenes/UI/OptionsDialog.tscn")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Battle/Monster.tscn")

func _ready():
	AudioManager.new().play_sound("quran-intro-1")

func _on_newgame_Button_pressed():
	get_tree().change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_LoadGameButton_pressed():
	get_tree().change_scene("res://Scenes/LoadingScene.tscn")

func _on_Options_pressed():
	var dialog = OptionsDialog.instance()
	self.add_child(dialog)
	dialog.popup_centered()
