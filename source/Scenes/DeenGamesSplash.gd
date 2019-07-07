extends Node2D

const _FADE_SECONDS = 1
const _SHOW_SECONDS = 3

func _ready():
	var tree = get_tree()
	
	$Logo.modulate = Color(1, 1, 1, 0)
	
	# Tween starts before display renders, so add a bit of delay before we start
	yield(tree.create_timer(0.5), 'timeout')
	$AudioStreamPlayer.play()
	
	# Fade in
	var tween = Tween.new()
	tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), _FADE_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	add_child(tween)
	tween.start()
	yield(tree.create_timer(_FADE_SECONDS), 'timeout')
	
	# Chill
	yield(tree.create_timer(_SHOW_SECONDS), 'timeout')
	
	# Fade out
	tween = Tween.new()
	tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), _FADE_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	add_child(tween)
	tween.start()
	yield(tree.create_timer(_FADE_SECONDS), 'timeout')
	
	tree.change_scene("res://Scenes/Title.tscn")
