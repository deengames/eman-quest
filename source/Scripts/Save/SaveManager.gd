extends Node

static func save_game(game_data, slot_name):
	var packed_scene = PackedScene.new()
	packed_scene.pack(game_data.player_data)
	var path = _get_path(slot_name)
	ResourceSaver.save(path, packed_scene)

static func load_game(slot_name):
#	var path = _get_path(slot_name)
#	var packed_scene = load(path)
#	var instance = packed_scene.instance()
#	return instance
	var path = "user://save-1.tscn"
	var packed_scene = load(path)
	var instance = packed_scene.instance()
	return instance

static func _get_path(slot_name):
	return "user://save-" + slot_name + ".tscn"