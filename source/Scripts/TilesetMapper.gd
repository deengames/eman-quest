extends Node

var _tileset

const _GENERATORS = {
	"Forest": preload("res://Scripts/Generators/ForestGenerator.gd"),
	"Cave": preload("res://Scripts/Generators/CaveGenerator.gd"),
	"Dungeon": preload("res://Scripts/Generators/DungeonGenerator.gd"),
}

func _init(tileset):
	self._tileset = tileset

func load_tileset_mapping():
	var to_return = {} # name => id
	
	var ids = self._tileset.get_tiles_ids()
	for id in ids:
		var name = self._tileset.tile_get_name(id)
		to_return[name] = id
	
	return to_return

func get_entity_tiles(map_type):
	var divider = map_type.find('/')
	if divider > -1:
		map_type = map_type.substr(0, divider)
		
	if map_type in _GENERATORS:
		var generator = _GENERATORS[map_type]
		return generator.ENTITY_TILES
	
	return {}
	