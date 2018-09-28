extends Area2D

const StoryWindow = preload("res://Scenes/UI/StoryWindow.tscn")

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		body.free()
		self._show_endgame_story()

func _show_endgame_story():
	var story_window = StoryWindow.instance()
	story_window.show_ending_story()
	get_tree().get_root().add_child(story_window)
	story_window.popup_centered()