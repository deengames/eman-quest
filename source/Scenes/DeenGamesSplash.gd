extends Node2D

const OptionsSaver = preload("res://Scripts/OptionsSaver.gd")

const _FADE_SECONDS = 1
const _SHOW_SECONDS = 3

var _GAME_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var _GAME_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

func _ready():
	var data = OptionsSaver.load()
	
	if data == null:
		data = {
			"zoom": 100,
			"monsters_chase": Features.is_enabled("monsters chase you"),
			"is_first_run": true,
			"is_full_screen": true,
			# ranges from -40 (muted) to 0 (full volume)
			"background_volume": 0,
			"sfx_volume": 0,
			"tile_display_multiplier": float(1)
		}

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

	var tree = get_tree()
	
	$Logo.modulate = Color(1, 1, 1, 0)
	
	# Tween starts before display renders, so add a bit of delay before we start
	yield(tree.create_timer(0.5), 'timeout')
	$AudioStreamPlayer.play()
	
	# Fade in
	var tween = Tween.new()
	tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), _FADE_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	add_child(tween)
	tween.start()
	yield(tree.create_timer(_FADE_SECONDS), 'timeout')
	
	# Chill
	yield(tree.create_timer(_SHOW_SECONDS), 'timeout')
	
	# Fade out
	tween = Tween.new()
	tween.interpolate_property($Logo, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), _FADE_SECONDS, Tween.TRANS_LINEAR, Tween.EASE_IN)
	add_child(tween)
	tween.start()
	yield(tree.create_timer(_FADE_SECONDS + 0.1), 'timeout')
	
	tree.change_scene("res://Scenes/Title.tscn")
