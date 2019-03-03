extends WindowDialog

func _on_ZoomOutToggle_toggled(button_pressed):
	Features.set_state("zoom-out maps", button_pressed)