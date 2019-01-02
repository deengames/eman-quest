extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const TweenHelper = preload("res://Scripts/TweenHelper.gd")

const _FADE_TIME_SECONDS = 0.5

var _audio_manager = AudioManager.new()

var _ayaat = ["quran-intro-1", "quran-intro-2"]
var _currently_playing = 0

func _ready():
	_audio_manager.connect("sound_finished", self, "_play_next_ayah")
	self._display_current_ayah()

func _play_next_ayah():
	self._currently_playing += 1
	if self._currently_playing < len(_ayaat):
		self._display_current_ayah()
	else:
		# DONE. Launch game.
		yield(get_tree().create_timer(1), 'timeout')
		SceneManagement.change_scene_to(get_tree(), Globals.maps["Home"])
		get_tree().current_scene.show_intro_events()

func _display_current_ayah():
	var audio = self._ayaat[self._currently_playing]
	_audio_manager.play_sound(audio)
	
	if self._currently_playing > 0:
		var current_ayah_image = self.get_node("intro-" + str(self._currently_playing))
		#TweenHelper.new().fade_out(self, current_ayah_image, _FADE_TIME_SECONDS).start()
		current_ayah_image.visible = false
	
	var next_ayah_image = self.get_node("intro-" + str(self._currently_playing + 1))
	next_ayah_image.visible = true
	#TweenHelper.new().fade_in(self, next_ayah_image, _FADE_TIME_SECONDS).start()