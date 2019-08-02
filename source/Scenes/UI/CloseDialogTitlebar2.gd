extends HBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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