extends Area2D

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		body.free()
		get_tree().current_scene.get_node("UI").show_ending_story()
