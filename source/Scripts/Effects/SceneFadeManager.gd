extends Node

const _WHITE = Color(1, 1, 1, 1)
const _BLACK = Color(0, 0, 0, 1)

static func fade_out(root, animation_time_seconds):
	return _fade(root, animation_time_seconds, _WHITE, _BLACK)

static func fade_in(root, animation_time_seconds):
	return _fade(root, animation_time_seconds, _BLACK, _WHITE)
	
static func _fade(root, animation_time_seconds, start_colour, end_colour):
	var canvas_modulate = CanvasModulate.new()
	root.add_child(canvas_modulate)
	
	var tween = Tween.new()
	tween.interpolate_property(canvas_modulate, "color", start_colour, end_colour, animation_time_seconds, Tween.TRANS_LINEAR, Tween.EASE_IN)
	root.add_child(tween)
	tween.start()
	return [canvas_modulate, tween]