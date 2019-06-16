extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
const OptionsDialog = preload("res://Scenes/UI/OptionsDialog.tscn")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

var _audio

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
	
	_audio = AudioManager.new()
	_audio.play_sound("title")
	_audio.add_click_noise_to_controls(self)

func _play_button_click():
	var audio_player = AudioManager.new()
	add_child(audio_player)
	audio_player.play_sound("button-click")

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

func _on_Node2D_tree_exited():
	_audio.clean_up_audio()
