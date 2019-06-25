extends PopupPanel

const AudioManager = preload("res://Scripts/AudioManager.gd")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

var _GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var _GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")
var _target_zoom = 100

func _ready():
	AudioManager.new().add_click_noise_to_controls(self)
	$ZoomOutToggle.pressed = Features.is_enabled("zoom-out maps")
	$MonstersChaseToggle.pressed = Features.is_enabled("monsters chase you")
	
	# Set zoom slider to closest value
	var window_size = OS.window_size
	var zoom_x = window_size.x / _GAME_WIDTH
	var zoom_y = window_size.y / _GAME_HEIGHT
	var zoom = min(zoom_x, zoom_y)
	_target_zoom = zoom
	$ZoomSlider.value = zoom * 100

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

func _on_ZoomSlider_value_changed(value):
	_target_zoom = $ZoomSlider.value / 100

func _on_PopupPanel_popup_hide():
	var new_size = Vector2(_GAME_WIDTH * _target_zoom, _GAME_HEIGHT * _target_zoom)
	OS.window_size = new_size
