extends Node

signal sound_finished

const AudioFilePlayerClass = preload("res://Scenes/AudioFilePlayer.tscn")
var AudioManger = get_script()

const BG_AUDIO_DB_OFFSET = -10

###### SOURCE: https://godot.readthedocs.io/en/3.0/tutorials/3d/fps_tutorial/part_six.html#doc-fps-tutorial-part-six
# ------------------------------------
# All of the audio files.

# You will need to provide your own sound files.
var audio_clips = {
	# Qur'an audios
	"quran-intro-1": preload("res://assets/audio/quran-17-23.ogg"),
	"quran-intro-2": preload("res://assets/audio/quran-17-24.ogg"),
	"quran-finale-1": preload("res://assets/audio/quran-14-41.ogg"),
	"quran-finale-2": preload("res://assets/audio/quran-14-42.ogg"),
	
	# Dungeon background audios
	"slime-forest-bgs": preload("res://assets/audio/bgs/Slime-Forest.ogg"),
	"frost-forest-bgs": preload("res://assets/audio/bgs/Frost-Forest.ogg"),
	"death-forest-bgs": preload("res://assets/audio/bgs/Death-Forest.ogg"),
	"river-cave-bgs": preload("res://assets/audio/bgs/River-Cave.ogg"),
	"lava-cave-bgs": preload("res://assets/audio/bgs/Lava-Cave.ogg"),
	"castle-dungeon-bgs": preload("res://assets/audio/bgs/Castle-Dungeon.ogg"),
	"desert-dungeon-bgs": preload("res://assets/audio/bgs/Desert-Dungeon.ogg"),
	
	# Static map background audios
	"waterfall-cliff": preload("res://assets/audio/bgs/Waterfall-Cliff.ogg"),
	"home": preload("res://assets/audio/bgs/Home.ogg"),
	
	# SFX
	"button-click": preload("res://assets/audio/sfx/button-click.ogg")
}

var audio_instances = []

func add_button_noise_to_buttons(scene):
	for child in scene.get_children():
		if child is Button:
			child.connect("pressed", self, "_play_button_click")

func _play_button_click():
	play_sound("button-click")

func play_sound(audio_clip_key, volume_db = 0):
	if audio_clips.has(audio_clip_key):
		var audio_player = AudioFilePlayerClass.instance()
		
		Globals.add_child(audio_player)
		audio_instances.append(audio_player)
		
		audio_player.should_loop = false
		audio_player.play_sound(audio_clips[audio_clip_key], volume_db)
		audio_player.connect("finished", self, "_sound_finished")
	else:
		print ("ERROR: cannot play sound {key} that is not defined in audio_clips dictionary!".format({key = audio_clip_key}))
# ------------------------------------

func remove_sound(audio):
	var index = audio_instances.find(audio)
	audio_instances.remove(index)

func clean_up_audio():
	for sound in audio_instances:
		if (sound != null):
			sound.queue_free()
		
	audio_instances.clear()

###
# If this isn't firing, check that your .ogg doesn't show Loop checked under Import
# (next to Scene tab, top-right of Godot 3.0 editor).
# If it does, uncheck and click Reimport.
###
func _sound_finished(audio):
	self.remove_sound(audio)
	self.emit_signal("sound_finished")