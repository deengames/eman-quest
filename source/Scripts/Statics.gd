extends Node

const AreaMap = preload("res://Entities/AreaMap.gd")
const Boss = preload("res://Entities/Battle/Boss.gd")
const DictionaryHelper = preload("res://Scripts/DictionaryHelper.gd")
const Equipment = preload("res://Entities/Equipment.gd")
const KeyItem = preload("res://Entities/KeyItem.gd")
const MapDestination = preload("res://Entities/MapDestination.gd")
const Monster = preload("res://Entities/Battle/Monster.gd")
const PlayerData = preload("res://Entities/PlayerData.gd")
const Quest = preload("res://Entities/Quest.gd")
const Room = preload("res://Entities/Room.gd")
const TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")
const TreasureChest = preload("res://Entities/TreasureChest.gd")

static func make_AreaMap(dict):
	var map = AreaMap.new(dict["map_type"], dict["variation"], dict["tileset_path"],
		dict["tiles_wide"], dict["tiles_high"], dict["area_type"])
	
	map.transitions = DictionaryHelper.array_from_dictionary(dict["transitions"])
	map.tiles_wide = dict["tiles_wide"]
	map.tiles_high = dict["tiles_high"]
	map.map_type = dict["map_type"]
	map.tile_data = DictionaryHelper.array_from_dictionary(dict["tile_data"])
	map.monsters = DictionaryHelper.dictionary_values_from_dictionary(dict["monsters"])
	map.treasure_chests = DictionaryHelper.array_from_dictionary(dict["treasure_chests"])
	map.bosses = DictionaryHelper.dictionary_values_from_dictionary(dict["bosses"])
	map.tileset_path = dict["tileset_path"]
	map.entrance_from_overworld = DictionaryHelper.dict_to_vector2(dict["entrance_from_overworld"])
	map.grid_x = dict["grid_x"]
	map.grid_y = dict["grid_y"]

	return map

static func make_Boss(dict):
	var to_return = Boss.new()
	to_return.initialize(dict["x"], dict["y"], dict["data"], Statics.make_KeyItem(dict["key_item"]))
	to_return.is_alive = dict["is_alive"]
	to_return.data_object = dict["data"]
	to_return.events = dict["events"]
	to_return.attach_quest_npcs = dict["attach_quest_npcs"]
	to_return.replace_with_npc = dict["replace_with_npc"]
	return to_return
	
static func make_Equipment(dictionary):
	var equipment = Equipment.new(dictionary["type"], dictionary["equipment_name"],
		dictionary["primary_stat"],
		dictionary["secondary_stat"])
	
	equipment.primary_stat_modifier = dictionary["primary_stat_modifier"]
	equipment.secondary_stat_modifier = dictionary["secondary_stat_modifier"]
	
	return equipment

static func make_KeyItem(dict):
	var to_return = KeyItem.new()
	to_return.initialize(dict["item_name"], dict["description"])
	return to_return

static func make_MapDestination(dict):
	if dict == null:
		return null
	
	var target_map = dict["target_map"]
	if typeof(target_map) != TYPE_STRING:
		# Even if we do nothing here, transition works. #lolwut?
		target_map = Statics.make_Room(target_map)
		
	return MapDestination.new(
		DictionaryHelper.dict_to_vector2(dict["my_position"]),
		target_map,
		DictionaryHelper.dict_to_vector2(dict["target_position"]),
		dict["direction"]
	)

static func make_Monster(dict):
	if dict == null:
		return null
		
	var to_return = Monster.new()
	var data = dict["data"]
	to_return.initialize(dict["x"], dict["y"])
	# needed for loading and re-instantiating on map
	#to_return.data_object = data
	to_return.data = data
	return to_return

static func make_PlayerData(dict):
	var to_return = PlayerData.new()
	to_return.level = dict["level"]
	to_return.experience_points = dict["experience_points"]
	to_return.health = dict["health"]
	to_return.strength = dict["strength"]
	to_return.defense = dict["defense"]
	to_return.num_actions = dict["num_actions"]
	to_return.unassigned_stats_points = dict["unassigned_stats_points"]
	to_return.assigned_points = dict["assigned_points"]
	to_return.weapon = Statics.make_Equipment(dict["weapon"])
	to_return.armour = Statics.make_Equipment(dict["armour"])
	to_return.equipment = DictionaryHelper.array_from_dictionary(dict["equipment"])
	to_return.key_items = DictionaryHelper.array_from_dictionary(dict["key_items"])
	to_return.tech_points = dict["tech_points"]
	to_return.play_time_seconds = dict["play_time_seconds"]
	return to_return

static func make_Quest(dict):
	var to_return = Quest.new()
	to_return.bosses = dict["bosses"]
	to_return.attach_quest_npcs = dict["attach_quest_npcs"]
	# HACK: always use the freshest data.
	#to_return.final_boss_data = dict["final_boss_data"]
	to_return.final_boss_data = Quest.new().final_boss_data
	return to_return
	
static func make_Room(dict):
	var to_return = Room.new(dict["grid_x"], dict["grid_y"])
	to_return.area_type = dict["area_type"]
	
	if dict.has("connections"):
		for direction in dict["connections"]:
			var obj = dict["connections"][direction]
			to_return["connections"][direction] = Statics.make_Room(obj)
		
	return to_return

static func make_TreasureChest(dict):
	var to_return = TreasureChest.new()
	var contents = Statics.make_Equipment(dict["contents"])
	to_return.initialize(dict["tile_x"], dict["tile_y"], contents)
	to_return.is_opened = dict["is_opened"]
	return to_return

static func make_TwoDimensionalArray(dict):
	var to_return = TwoDimensionalArray.new(dict["width"], dict["height"])
	to_return._data = dict["data"]
	return to_return