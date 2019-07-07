extends Node2D

const _FADE_SECONDS = 1
const _SHOW_SECONDS = 3

func _ready():
	var tree = get_tree()
	var root = tree.get_root()
	
	$Logo.modulate = Color(1, 1, 1, 0)
	
	print("Start")
	print("In")
	# Fade in
	var tween = Tween.new()
	tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), _FADE_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	root.add_child(tween)
	tween.start()
	yield(tree.create_timer(_FADE_SECONDS), 'timeout')
	
	print("Chill")
	# Chill
	yield(tree.create_timer(_SHOW_SECONDS), 'timeout')
	
	# Fade out
	print("Out")
	tween = Tween.new()
	tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), _FADE_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	root.add_child(tween)
	tween.start()
	yield(tree.create_timer(_FADE_SECONDS), 'timeout')
	
	print("Done")