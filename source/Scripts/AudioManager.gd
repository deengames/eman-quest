extends Node

signal sound_finished

###### SOURCE: https://godot.readthedocs.io/en/3.0/tutorials/3d/fps_tutorial/part_six.html#doc-fps-tutorial-part-six
# ------------------------------------
# All of the audio files.

# You will need to provide your own sound files.
var audio_clips = {
	"quran-intro-1": preload("res://assets/audio/quran-17-23.ogg"),
	"quran-intro-2": preload("res://assets/audio/quran-17-24.ogg"),
	"quran-finale-1": preload("res://assets/audio/quran-14-41.ogg"),
	"quran-finale-2": preload("res://assets/audio/quran-14-42.ogg")
}

const AudioFilePlayerClass = preload("res://Scenes/AudioFilePlayer.tscn")
var audio_instances = []

func play_sound(audio_clip_key, loop_sound=false, sound_position=null):
	if audio_clips.has(audio_clip_key):
		var audio_player = AudioFilePlayerClass.instance()
		
		Globals.add_child(audio_player)
		audio_instances.append(audio_player)
		
		audio_player.should_loop = loop_sound
		audio_player.play_sound(audio_clips[audio_clip_key], sound_position)
		#audio_player.play_sound(load("res://assets/audio/test.wav"))
		audio_player.connect("finished", self, "_sound_finished")
	else:
		print ("ERROR: cannot play sound {key} that is not defined in audio_clips dictionary!".format({key = audio_clip_key}))
# ------------------------------------

###
# If this isn't firing, check that your .ogg doesn't show Loop checked under Import
# (next to Scene tab, top-right of Godot 3.0 editor).
# If it does, uncheck and click Reimport.
###
func _sound_finished(audio):
	self.remove_sound(audio)
	self.emit_signal("sound_finished")

func remove_sound(audio):
	var index = audio_instances.find(audio)
	audio_instances.remove(index)

func clean_up_audio():
	for sound in audio_instances:
		if (sound != null):
			sound.queue_free()
		
	audio_instances.clear()