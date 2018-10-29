extends Node

const _FULLY_VISIBLE = Color(1, 1, 1, 1)
const _FULLY_INVISIBLE = Color(1, 1, 1, 0)
var tween

# Used to fade something out over time
func _init():
	self.tween = Tween.new()

func fade_out(current_scene, fade_target, fade_out_time):
	var start_colour = _FULLY_VISIBLE
	var end_colour = _FULLY_INVISIBLE
	self.tween.interpolate_property(fade_target, "modulate", start_colour, end_colour, fade_out_time, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	current_scene.add_child(self.tween)
	return self # for chaining with constructor

func fade_in(current_scene, fade_target, fade_in_time):
	var start_colour = _FULLY_INVISIBLE
	var end_colour = _FULLY_VISIBLE
	fade_target.modulate = _FULLY_INVISIBLE
	self.tween.interpolate_property(fade_target, "modulate", start_colour, end_colour, fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	current_scene.add_child(self.tween)
	return self

func start():
	if not self.tween.is_active():
		self.tween.start()