extends Node

const AreaMap = preload("res://Entities/AreaMap.gd")
const DictionaryHelper = preload("res://Scripts/DictionaryHelper.gd")
const PlayerData = preload("res://Entities/PlayerData.gd")

static func save(save_id):
	var maps = {}
	for map_type in Globals.maps.keys():
		var source_map = Globals.maps[map_type]
		var map_data
		
		if typeof(source_map) == TYPE_ARRAY:
			map_data = DictionaryHelper.array_to_dictionary(source_map)
		else:
			map_data = source_map.to_dict()
			
		maps[map_type] = map_data
	
	maps = to_json(maps)	
	var player_data = to_json(Globals.player_data.to_dict())
	var story_data = to_json(Globals.story_data)
	var overworld_position = to_json(DictionaryHelper.vector2_to_dict(Globals.overworld_position))
	
	var save_game = File.new()
	save_game.open(_get_path(save_id), File.WRITE)
	
	save_game.store_line(maps)
	save_game.store_line(player_data)
	save_game.store_line(story_data)
	save_game.store_line(overworld_position)
	
	save_game.close()

static func load(save_id):
	var save_game = File.new()
	var path = _get_path(save_id)
	
	if not save_game.file_exists(path):
		return # Error! We don't have a save to load.
	
	save_game.open(path, File.READ)
	
	var maps_data = parse_json(save_game.get_line())
	var player_data = parse_json(save_game.get_line())
	var story_data = parse_json(save_game.get_line())
	var overworld_position_data = parse_json(save_game.get_line())
	
	save_game.close()
	
	for key in maps_data.keys():
		# Derp
		if key == "Overworld":
			Globals.maps[key] = AreaMap.from_dict(maps_data[key])
		else:
			Globals.maps[key] = []
			for data in maps_data[key]:
				Globals.maps[key].append(AreaMap.from_dict(data))
	
	Globals.player_data = PlayerData.from_dict(player_data)
	Globals.story_data = story_data
	Globals.overworld_position = DictionaryHelper.dict_to_vector2(overworld_position_data)

static func _get_path(save_id):
	return "user://save-" + str(save_id) + ".save"