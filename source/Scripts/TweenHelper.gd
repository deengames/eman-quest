extends Node

var tween

func _init(current_scene, fade_target, fade_time):
	self.tween = Tween.new()
	var start_colour = Color(1, 1, 1, 1)
	var end_colour = Color(1, 1, 1, 0)
	tween.interpolate_property(fade_target, "modulate", start_colour, end_colour, fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	current_scene.add_child(tween)

func start():
	if not tween.is_active():
		tween.start()