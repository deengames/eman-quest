extends StaticBody2D

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		self._show_endgame_story()

func _show_endgame_story():
	pass