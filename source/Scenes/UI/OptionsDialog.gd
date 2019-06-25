extends PopupPanel

const AudioManager = preload("res://Scripts/AudioManager.gd")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

var _GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var _GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	AudioManager.new().add_click_noise_to_controls(self)
	$MonstersChaseToggle.pressed = Features.is_enabled("monsters chase you")
	$Zoom/ZoomSlider.value = Globals.zoom

func title(value):
	$CloseDialogTitlebar.title = value

func _on_MonstersChaseToggle_toggled(button_pressed):
	Features.set_state("monsters chase you", button_pressed)
	_save_options()
	
func _save_options():
	var options = {
		"zoom": Globals.zoom,
		"monsters_chase": $MonstersChaseToggle.pressed,
		"is_first_run": false # always false on save
	}
	
	OptionsSaver.save(options)

func _on_ZoomSlider_value_changed(value):
	Globals.zoom = $Zoom/ZoomSlider.value
	_update_zoom_label()
	_save_options()

# Apply specified zoom on popup close
func _on_PopupPanel_popup_hide():
	var percent_zoom = Globals.zoom / 100
	var new_size = Vector2(_GAME_WIDTH * percent_zoom, _GAME_HEIGHT * percent_zoom)
	OS.window_size = new_size

func _update_zoom_label():
	$Zoom/ZoomLabel.text = "Zoom (" + str(Globals.zoom) + "%):"
	