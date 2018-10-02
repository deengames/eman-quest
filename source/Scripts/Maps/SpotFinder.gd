extends Node

static func find_empty_spot(map_width, map_height, object_map, occupied_spots, entrance_position):
	var x = Globals.randint(0, map_width - 1)
	var y = Globals.randint(0, map_height - 1)
	
	while (object_map.get(x, y) == "Bush" or
		entrance_position.find([x, y]) > -1 or
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