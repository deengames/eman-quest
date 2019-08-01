extends PopupPanel

const AudioManager = preload("res://Scripts/AudioManager.gd")
const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

var _GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var _GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	AudioManager.new().add_click_noise_to_controls(self)
	$Zoom/ZoomSlider.value = Globals.zoom
	$FullScreen.pressed = Globals.is_full_screen
	$BackgroundAudio/BackgroundAudioSlider.value = Globals.background_volume
	$SfxAudio/SfxAudioSlider.value = Globals.sfx_volume
	$TileDisplayTime/TileDisplayTimeSlider.value = Globals.tile_display_multiplier
	self._on_TileDisplayTimeSlider_value_changed(Globals.tile_display_multiplier)
	
func title(value):
	$CloseDialogTitlebar.title = value

func _save_options():
	var options = {
		"zoom": Globals.zoom,
		"is_first_run": false, # always false because we ran the first run
		"is_full_screen": Globals.is_full_screen,
		"background_volume": Globals.background_volume,
		"sfx_volume": Globals.sfx_volume,
		"tile_display_multiplier": Globals.tile_display_multiplier
	}
	
	OptionsSaver.save_preferences(options)

func _on_ZoomSlider_value_changed(value):
	Globals.zoom = $Zoom/ZoomSlider.value
	_update_zoom_label()
	_save_options()

# Apply specified zoom on popup close
func _on_PopupPanel_popup_hide():
	if not Globals.is_full_screen:
		var percent_zoom = Globals.zoom / 100
		var new_size = Vector2(_GAME_WIDTH * percent_zoom, _GAME_HEIGHT * percent_zoom)
		OS.window_size = new_size
	
	OS.window_maximized = Globals.is_full_screen

func _update_zoom_label():
	$Zoom/ZoomLabel.text = "Zoom (" + str(Globals.zoom) + "%):"

func _on_FullScreen_toggled(button_pressed):
	Globals.is_full_screen = button_pressed
	$Zoom/ZoomSlider.editable = not button_pressed
	if not $Zoom/ZoomSlider.editable:
		Globals.zoom = 100
	_save_options()
	
func _on_BackgroundAudioSlider_value_changed(value):
	Globals.background_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background"), Globals.background_volume)
	_save_options()

func _on_SfxAudioSlider_value_changed(value):
	Globals.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Globals.sfx_volume)
	_save_options()

func _on_TileDisplayTimeSlider_value_changed(value):
	Globals.tile_display_multiplier = float(value)
	$TileDisplayTime/TileDisplayTimeLabel.text = "Battle: display tiles for " + str(value) + "s"
	_save_options()
