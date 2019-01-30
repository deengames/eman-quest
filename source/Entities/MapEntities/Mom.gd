extends Node2D

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const TweenHelper = preload("res://Scripts/TweenHelper.gd")

const _FADE_TIME_SECONDS = 1

func appear_wounded():
	$Dead.visible = true
	$Alive.visible = false

func _on_Node2D_body_entered(body):
	if Globals.beat_last_boss and body == Globals.player:
		self._show_post_game_events()

func _show_post_game_events():
	Globals.player.freeze()
		
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	var dialog_window = DialogueWindow.instance()
	current_scene.add_child(dialog_window)
	
	dialog_window.show_texts([
		["Mama", "You did it! You beat him! My child ..."],
		["Hero", "Mama, Baba, I'm just glad you're okay ..."],
		["Baba", "We're so proud of you and how you stand up for justice!"],
		["Hero", "..."],
		["Mama", "What's wrong, dear?"],
		["Hero", "Well ... it's just ..."],
		["Hero", "That ... creature ... isn't dead. It said it will just find someone else to use ..."],
		["Mama", "..."],
		["Baba", "That doesn't matter. As long as there is evil in the world, good people will stand up for justice."],
		["Hero", "..."],
		["Hero", "You're right, Baba ..."],
		["Baba", "I know I am. With patience, we can make it through any of life's trials."],
	])
	yield(dialog_window, "shown_all")
	dialog_window.queue_free()
	
	var target = self.get_parent().get_node("Blackout")
	# EPIC SIGH, player is above the tween object, changing Z by -1 makes him disappear
	Globals.player.visible = false

	var tween = Tween.new()
	self.add_child(tween)
	tween.interpolate_property(target, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 0.5), _FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(_FADE_TIME_SECONDS), 'timeout')
	
	# Ayaat
	
	tween.interpolate_property(target, "color", Color(0, 0, 0, 0.5), Color(0, 0, 0, 0), _FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(_FADE_TIME_SECONDS), 'timeout')
	
	# Choice: quit or not
	
	Globals.player.visible = true
	Globals.player.unfreeze()