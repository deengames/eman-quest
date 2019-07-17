extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")

const DOOR_TYPE = "metal"
	
func _on_Area2D_body_entered(body):
	if body == Globals.player:
		AudioManager.new().play_sound("open-{type}-door".format({"type": DOOR_TYPE}))
		self.queue_free()
		# TODO: emit signal and remove on parent. Throws an error at runtime:
		# "This function can't be used during the in/out signal."
		self.get_parent().remove_child(self)
