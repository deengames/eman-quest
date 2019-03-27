extends Node

const _WHITE = Color(1, 1, 1, 1)
const _BLACK = Color(0, 0, 0, 1)

static func fade_out(tree, animation_time_seconds):
	return _fade(tree, animation_time_seconds, _WHITE, _BLACK)

static func fade_in(tree, animation_time_seconds):
	return _fade(tree, animation_time_seconds, _BLACK, _WHITE)
	
static func _fade(tree, animation_time_seconds, start_colour, end_colour):
	var canvas_modulate = CanvasModulate.new()
	# Fixes jerky frame between fades; see: https://twitter.com/nightblade99/status/1109278972976623616
	canvas_modulate.color = start_colour
	var root = tree.get_root()
	root.add_child(canvas_modulate)
	
	var tween = Tween.new()
	tween.interpolate_property(canvas_modulate, "color", start_colour, end_colour, animation_time_seconds, Tween.TRANS_LINEAR, Tween.EASE_IN)
	root.add_child(tween)
	tween.start()
	
	yield(tween, "tween_completed")
	
	# pre_battle_position: non-null when the player is being freed
	if Globals.pre_battle_position == null and Globals.post_fade_position != null:
		if Globals.player != null:
			Globals.player.position = Globals.post_fade_position
		Globals.post_fade_position = null
	
	root.remove_child(tween)
	root.remove_child(canvas_modulate)