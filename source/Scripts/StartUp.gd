extends Node2D

const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

var _GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var _GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	print("D1: " + str(File.new().file_exists("user://EmanQuestPreferences.dat")))
	
	var data = OptionsSaver.load()
	
	if data == null:
		data = {
			"zoom": 100,
			"is_first_run": true,
			"is_full_screen": true,
			# ranges from -40 (muted) to 0 (full volume)
			"background_volume": 0,
			"sfx_volume": 0,
			"tile_display_multiplier": float(1)
		}

		OptionsSaver.save(data)

	var window_size = OS.window_size
	Globals.zoom  = data["zoom"]
	var zoom_percent = Globals.zoom / 100
	OS.window_size = Vector2(_GAME_WIDTH * zoom_percent, _GAME_HEIGHT * zoom_percent)
	
	Globals.is_full_screen = data["is_full_screen"]
	OS.window_maximized = Globals.is_full_screen
	
	Globals.background_volume = data["background_volume"]
	Globals.sfx_volume = data["sfx_volume"]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background"), Globals.background_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Globals.sfx_volume)

	Globals.tile_display_multiplier = float(data["tile_display_multiplier"])
