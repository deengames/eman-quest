extends Node

const AreaMap = preload("res://Entities/AreaMap.gd")
const DictionaryHelper = preload("res://Scripts/DictionaryHelper.gd")
const MapDestination = preload("res://Entities/MapDestination.gd")
const PlayerData = preload("res://Entities/PlayerData.gd")
const Quest = preload("res://Entities/Quest.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

# When I implemented this, as saves were then, this is what we got:
# Uncompressed:	7120kb
# Deflate:		 131kb
# ZSTD:			 150kb
# GZIP:			 152kb
# FastLZ:		 206kb
const _SAVE_COMPRESSION_MODE = File.COMPRESSION_DEFLATE  

const _MAPS_NOT_TO_SAVE = ["Home", "Final"]

static func save(save_id):
	var maps = {}
	
	for map_type in Globals.maps.keys():
		if not map_type in _MAPS_NOT_TO_SAVE:
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
	var current_map_data = to_json(Globals.current_map.to_dict())
	var player_position = to_json(DictionaryHelper.vector2_to_dict(Globals.player.position))
	
	var world_areas = to_json(Globals.world_areas) # Array of strings
	var quest = to_json(Globals.quest.to_dict())
	var seed_value = Globals.seed_value
	
	var save_game = File.new()
	# Use gzip because 2D arrays of ["Grass", "Grass", ...] will compres well
	save_game.open_compressed(_get_path(save_id), File.WRITE, _SAVE_COMPRESSION_MODE)
	
	save_game.store_line(maps)
	save_game.store_line(player_data)
	save_game.store_line(story_data)
	save_game.store_line(overworld_position)
	save_game.store_line(current_map_data)
	save_game.store_line(player_position)
	save_game.store_line(world_areas)
	save_game.store_line(quest)
	save_game.store_line(str(seed_value))
	
	save_game.close()

static func load(save_id, tree):
	var save_game = File.new()
	var path = _get_path(save_id)
	
	if not save_game.file_exists(path):
		return # Error! We don't have a save to load.
	
	save_game.open_compressed(path, File.READ, _SAVE_COMPRESSION_MODE)
	
	var maps_data = parse_json(save_game.get_line())
	var player_data = parse_json(save_game.get_line())
	var story_data = parse_json(save_game.get_line())
	var overworld_position_data = parse_json(save_game.get_line())
	var current_map_data = parse_json(save_game.get_line())
	var player_position_data = parse_json(save_game.get_line())
	var world_areas = parse_json(save_game.get_line())
	var quest_data = parse_json(save_game.get_line())
	var seed_value = parse_json(save_game.get_line())
	
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
	
	var current_map =  AreaMap.from_dict(current_map_data)
	Globals.current_map = current_map # Required to correctly load
	
	SceneManagement.change_map_to(tree, current_map)
	Globals.player.position = DictionaryHelper.dict_to_vector2(player_position_data)
	
	Globals.world_areas = world_areas
	Globals.quest = Quest.from_dict(quest_data)
	Globals.seed_value = seed_value

static func _get_path(save_id):
	return "user://save-" + str(save_id) + ".save"