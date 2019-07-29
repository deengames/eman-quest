extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
const LoadingScene = preload("res://Scenes/LoadingScene.tscn")
const OptionsDialog = preload("res://Scenes/UI/OptionsDialog.tscn")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

var _audio

func _ready():
	print("D3: " + str(File.new().file_exists("user://EmanQuestPreferences.dat")))
	var data = OptionsSaver.load()
	return
	Globals.is_full_screen = data["is_full_screen"]
	
	Globals.is_first_run = data["is_first_run"]
	if Globals.is_first_run:
		Globals.is_full_screen = true
		Globals.is_first_run = false
		_on_Options_pressed()
		OS.window_maximized = true
	
	var tree = get_tree()
	SceneFadeManager.fade_in(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	
	_audio = AudioManager.new()
	_audio.play_sound("title")
	_audio.add_click_noise_to_controls(self)

func _play_button_click():
	var audio_player = AudioManager.new()
	add_child(audio_player)
	audio_player.play_sound("button-click")

func _on_newgame_Button_pressed():
	print("D4: " + str(File.new().file_exists("user://EmanQuestPreferences.dat")))
	_play_button_click()
	$VBoxContainer/NewGameButton.disabled = true
	var tree = get_tree()
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	tree.change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_LoadGameButton_pressed():
	_play_button_click()
	$VBoxContainer/LoadGameButton.disabled = true
	var loading_scene = LoadingScene.instance()
	add_child(loading_scene)
	loading_scene.connect("tree_exiting", self, "_enable_load")

func _enable_load():
	$VBoxContainer/LoadGameButton.disabled = false
	
func _on_Options_pressed():
	_play_button_click()
	var dialog = OptionsDialog.instance()
	dialog.title("Options")
	dialog.popup_exclusive = true
	self.add_child(dialog)
	dialog.popup_centered()

func _on_Node2D_tree_exited():
	_audio.clean_up_audio()
