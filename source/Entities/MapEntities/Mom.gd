extends Node2D

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const QuranScene = preload("res://Scenes/QuranScene.tscn")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")
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
	
	var home_scene = self.get_parent()
	var target = home_scene.get_node("Blackout")
	# EPIC SIGH, player is above the tween object, changing Z by -1 makes him disappear
	Globals.player.visible = false

	var tween = Tween.new()
	self.add_child(tween)
	var r = 20/255
	var g = 16/255
	var b = 31/255
	
	tween.interpolate_property(target, "color", Color(r, g, b, 0), Color(r, g, b, 0.5), _FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(_FADE_TIME_SECONDS), 'timeout')
	
	# Fade in and play ayaat
	var qs = QuranScene.instance()
	qs.set_ayaat(["quran-finale-1", "quran-finale-2"])
	SceneManagement.change_scene_to(get_tree(), qs)