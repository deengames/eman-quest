extends Node

func load_tileset_mapping(tileset):
	var to_return = {} # name => id
	
	var ids = tileset.get_tiles_ids()
	for id in ids:
		var name = tileset.tile_get_name(id)
		to_return[name] = id
	
	return to_return