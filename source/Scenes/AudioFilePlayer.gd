extends Node

var audio_node = null
export var should_loop = false

signal finished # final finish, not "looping now" restart
signal looping 

func _ready():
	audio_node = $AudioStreamPlayer
	audio_node.stop()
	
func play_sound(audio_stream, volume_db = 0):
	audio_node.volume_db = volume_db
	audio_node.stream = audio_stream
	audio_node.play()
	
func _on_AudioStreamPlayer_finished():
	if self.should_loop:
		audio_node.play(0.0)
		emit_signal("looping", self)
	else:
		emit_signal("finished", self)
		audio_node.stop()

	queue_free()