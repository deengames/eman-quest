extends Node2D

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		# TODO: play a click-click noise
		self.queue_free()
		self.get_parent().remove_child(self)
