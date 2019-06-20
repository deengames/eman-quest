extends Panel

const _BUTTON_AREA_SIZE = 32 # px

# It's magic. You add it to a popup window, and it resizes automatically. Closing
# it (click the X button) also closes the underlying popup.
func _ready():
	var parent = get_parent()
	
	margin_left = 0
	margin_top = -_BUTTON_AREA_SIZE
	margin_bottom = 0
	
	if "margin_right" in parent:
		margin_right = parent.margin_right
	elif "width" in parent:
		margin_right = parent.width
	
	$Area2D.position.x = margin_right - _BUTTON_AREA_SIZE
	# for display purposes
	$Area2D/Label.margin_left -= 6

func _on_Area2D_input_event(viewport, event, shape_idx):
	# For some reason, event.pressed is always false. Even when I click. Really, Godot?
	if (event is InputEventMouseButton) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		var parent = get_parent()
		parent.remove_child(self)
		if parent is Popup:
			parent.emit_signal("popup_hide")
		
		parent.get_parent().remove_child(parent)
