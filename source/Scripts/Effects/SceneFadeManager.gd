extends Node

const _WHITE = Color(1, 1, 1, 1)
const _BLACK = Color(0, 0, 0, 1)

static func fade_out(tree, animation_time_seconds):
	return _fade(tree, animation_time_seconds, _WHITE, _BLACK)

static func fade_in(tree, animation_time_seconds):
	return _fade(tree, animation_time_seconds, _BLACK, _WHITE)
	
static func _fade(tree, animation_time_seconds, start_colour, end_colour):
	# null when loading game. Player isn't created yet (map isn't loaded yet)
	if Globals.player != null:
		Globals.player.freeze()
	
	var canvas_modulate = CanvasModulate.new()
	var root = tree.get_root()
	root.add_child(canvas_modulate)
	
	var tween = Tween.new()
	tween.interpolate_property(canvas_modulate, "color", start_colour, end_colour, animation_time_seconds, Tween.TRANS_LINEAR, Tween.EASE_IN)
	root.add_child(tween)
	tween.start()
	
	# Calling yield causes scene management to break.
	# Add a yield here, start a new game, and leave the world map; you'll see: madness.
	# See: https://twitter.com/nightblade99/status/1105664856181493760
	########## TODO: figure out how to do a yield in a yield?
	#yield(tree.create_timer(animation_time_seconds), 'timeout')
	
	yield(tween, "tween_completed")
	
	root.remove_child(tween)
	root.remove_child(canvas_modulate)