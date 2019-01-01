extends Node

var audio_node = null
export var should_loop = false

signal sound_finished # final finish, not "looping now" restart

func _ready():
	audio_node = $AudioStreamPlayer
	audio_node.connect("finished", self, "sound_finished")
	audio_node.stop()
	
func play_sound(audio_stream, position=null):
	audio_node.stream = audio_stream
	audio_node.play()
	
func sound_finished():
	if self.should_loop:
		audio_node.play(0.0)
		#emit loop event
	else:
		emit_signal("sound_finished", self)
		audio_node.stop()

	queue_free()