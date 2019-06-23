extends Node2D

const _PADDING = 8

# It's magic. You add it to a popup window, and it resizes automatically. Closing
# it (click the X button) also closes the underlying popup.
func _ready():
	var parent = get_parent()
	
	if "margin_right" in parent:
		$Panel.margin_right = parent.margin_right
	elif "width" in parent:
		$Panel.margin_right = parent.width
	
	var button = $Panel/Label
	var _BUTTON_SIZE = button.margin_right - button.margin_left
	# move button to RHS
	button.margin_right = $Panel.margin_right
	button.margin_left = $Panel.margin_right - _BUTTON_SIZE
	# Position button above parent control
	# THIS BREAKS INPUT EVENTS
	# TODO: maybe create a new control that wraps/offsets the parent node and us,
	# so that we don't have to set a negative y-position.
	# (make a new control, add us at (0, 0), add parent at (0, 58), offset)
	self.position.y = -button.margin_bottom
	print(str(self.position))

func _on_Button_pressed():
	print("!")
	var parent = get_parent()
	parent.remove_child(self)
	if parent is Popup:
		parent.emit_signal("popup_hide")
	
	parent.get_parent().remove_child(parent)