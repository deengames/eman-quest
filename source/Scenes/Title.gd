extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
const OptionsDialog = preload("res://Scenes/UI/OptionsDialog.tscn")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

var _GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var _GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

var _audio

func _ready():
	var data = OptionsSaver.load()
	
	if data == null:
		data = {
			"zoom": 100,
			"monsters_chase": Features.is_enabled("monsters chase you"),
			"is_first_run": true,
			"is_full_screen": true
		}
	
	var window_size = OS.window_size
	Globals.zoom  = data["zoom"]
	var zoom_percent = Globals.zoom / 100
	OS.window_size = Vector2(_GAME_WIDTH * zoom_percent, _GAME_HEIGHT * zoom_percent)
	
	Features.set_state("monsters chase you", data["monsters_chase"])
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
	$NewGameButton.disabled = true
	var tree = get_tree()
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	tree.change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_LoadGameButton_pressed():
	$LoadGameButton.disabled = true
	var tree = get_tree()
	
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	
	tree.change_scene("res://Scenes/LoadingScene.tscn")

func _on_Options_pressed():
	var dialog = OptionsDialog.instance()
	dialog.title("Options")
	dialog.popup_exclusive = true
	self.add_child(dialog)
	dialog.popup_centered()

func _on_Node2D_tree_exited():
	_audio.clean_up_audio()
