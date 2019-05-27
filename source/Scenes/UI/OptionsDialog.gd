extends WindowDialog

var OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

func _ready():
	var data = OptionsSaver.load()
	if data == null:
		data = {
			"zoom": Features.is_enabled("zoom-out maps"),
			"monsters_chase": Features.is_enabled("monsters chase you")
		}
	Features.set_state("zoom-out maps", data["zoom"])
	Features.set_state("monsters chase you", data["monsters_chase"])
	
	$ZoomOutToggle.pressed = data["zoom"]
	$MonstersChaseToggle.pressed = data["monsters_chase"]

func _on_ZoomOutToggle_toggled(button_pressed):
	Features.set_state("zoom-out maps", button_pressed)
	_save_options()

func _on_MonstersChaseToggle_toggled(button_pressed):
	Features.set_state("monsters chase you", button_pressed)
	_save_options()
	
func _save_options():
	var options = {
		"zoom": $ZoomOutToggle.pressed,
		"monsters_chase": $MonstersChaseToggle.pressed
	}
	
	OptionsSaver.save(options)