extends Node

const PADDING_FROM_MAP_EDGES = 5

static func find_empty_spot(map_width, map_height, object_map, occupied_spots):
	var x = Globals.randint(PADDING_FROM_MAP_EDGES, map_width - PADDING_FROM_MAP_EDGES - 1)
	var y = Globals.randint(PADDING_FROM_MAP_EDGES, map_height - PADDING_FROM_MAP_EDGES - 1)
	
	while (object_map.get(x, y) == "Bush" or
		occupied_spots.find([x, y]) > -1 or
		# Trees technically have empty space around them, so make sure
		# we're not in one of those tiles.
		object_map.get(x, y) == "Tree" or
		object_map.get(x - 1, y) == "Tree" or
		object_map.get(x, y - 1) == "Tree" or
		object_map.get(x - 1, y - 1) == "Tree"):
			x = Globals.randint(0, map_width - 1)
			y = Globals.randint(0, map_height - 1)
	
	return [x, y]