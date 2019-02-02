extends Node2D

const _CREDITS_TIME_SECONDS = 10
const _CONGRATS_FADE_TIME_SECONDS = 5
const _VISIBLE = Color(1, 1, 1, 1)
const _INVISIBLE = Color(1, 1, 1, 0)

func _ready():
	var tween = Tween.new()
	self.add_child(tween)

	# top starts at 660 (under screen), go to -660 (offscreen/above)
	tween.interpolate_property($CreditsLabel, "margin_top", 660, -660, _CREDITS_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

	yield(get_tree().create_timer(_CREDITS_TIME_SECONDS), 'timeout')

	# Fade in ~5s
	tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($TheEndLabel, "modulate", _INVISIBLE, _VISIBLE, _CONGRATS_FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(_CREDITS_TIME_SECONDS), 'timeout')
	tween.queue_free()

	# Thanks fade in ~5s
	tween = Tween.new()
	add_child(tween)
	tween.interpolate_property($ThanksLabel, "modulate", _INVISIBLE, _VISIBLE, _CONGRATS_FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(_CREDITS_TIME_SECONDS), 'timeout')
	tween.queue_free()
	
	# Both disappear ~5s
	tween = Tween.new()
	self.add_child(tween)
	tween.interpolate_property($TheEndLabel, "modulate", _VISIBLE, _INVISIBLE, _CONGRATS_FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	var tween2 = Tween.new()
	self.add_child(tween2)
	tween2.interpolate_property($ThanksLabel, "modulate", _VISIBLE, _INVISIBLE, _CONGRATS_FADE_TIME_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween2.start()
	yield(get_tree().create_timer(_CREDITS_TIME_SECONDS), 'timeout')
	
	tween.queue_free()
	tween2.queue_free()
	
	get_tree().change_scene("res://Scenes/Title.tscn")
	
func _on_credits_rolled():
	pass
