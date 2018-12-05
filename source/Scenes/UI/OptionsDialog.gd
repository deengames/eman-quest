extends WindowDialog

func _on_ZoomOutToggle_toggled(button_pressed):
	Features.set("zoom-out maps", button_pressed)