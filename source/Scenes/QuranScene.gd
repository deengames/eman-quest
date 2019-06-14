extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const TweenHelper = preload("res://Scripts/TweenHelper.gd")

const _FADE_TIME_SECONDS = 0.5

var _audio_manager = AudioManager.new()

var _ayaat = ["quran-intro-1"]
var _currently_playing = 0
var _autostart_game = true # true for new game, false for end-game

func _ready():
	_audio_manager.connect("sound_finished", self, "_play_next_ayah")
	self._display_current_ayah()
	
	var tree = get_tree()
	SceneFadeManager.fade_in(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	

func set_ayaat(ayaat):
	self._ayaat = ayaat
	self._autostart_game = false
	$SkipButton.visible = false

func _play_next_ayah():
	self._currently_playing += 1
	if self._currently_playing < len(_ayaat):
		self._display_current_ayah()
	else:
		# DONE. Launch game.
		yield(get_tree().create_timer(1), 'timeout')
		self._on_complete()

func _display_current_ayah():
	var audio = self._ayaat[self._currently_playing]
	_audio_manager.play_sound(audio)
	
	if self._currently_playing > 0:
		var current_ayah_image = self.get_node(self._ayaat[self._currently_playing - 1])
		#TweenHelper.new().fade_out(self, current_ayah_image, _FADE_TIME_SECONDS).start()
		current_ayah_image.visible = false
	
	var next_ayah_image = self.get_node(self._ayaat[self._currently_playing])
	next_ayah_image.visible = true
	#TweenHelper.new().fade_in(self, next_ayah_image, _FADE_TIME_SECONDS).start()

func _on_SkipButton_pressed():
	_audio_manager.clean_up_audio()
	self._on_complete()
	
func _on_complete():
	var tree = get_tree()
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	
	if self._autostart_game:
		SceneManagement.change_scene_to(tree, Globals.maps["Home"])
		tree.current_scene.show_intro_events()
	else:
		tree.change_scene("res://Scenes/CreditsScene.tscn")