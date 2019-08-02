extends HBoxContainer

var title = "" setget set_title, get_title

func set_title(title):
	$Title.text = title.to_upper()

func get_title():
	return $Panel/Title.text
	
func _on_Button_pressed():
	if not $Button.disabled:# and event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		$Button.disabled = true
		$AudioStreamPlayer.play()
		# Yield for the audio play-time
		yield(get_tree().create_timer(0.2), 'timeout')
		
		var owning_control = get_parent().get_parent()
		owning_control.remove_child(self)
		if owning_control is Popup:
			owning_control.emit_signal("popup_hide")
		
		var grandparent = owning_control.get_parent()
		if grandparent != null:
			grandparent.remove_child(owning_control)