extends PopupPanel

const AudioManager = preload("res://Scripts/AudioManager.gd")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

func _ready():
	AudioManager.new().add_click_noise_to_controls(self)
	$ZoomOutToggle.pressed = Features.is_enabled("zoom-out maps")
	$MonstersChaseToggle.pressed = Features.is_enabled("monsters chase you")

func title(value):
	$CloseDialogTitlebar.title = value

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