extends Node

const _PADDING_FROM_MAP_EDGES = 5
const _ISOLATION_DISTANCE_TILES = 10 # n-tile radius

static func find_empty_spot(map_width, map_height, object_map, occupied_spots):
	var x = Globals.randint(_PADDING_FROM_MAP_EDGES, map_width - _PADDING_FROM_MAP_EDGES - 1)
	var y = Globals.randint(_PADDING_FROM_MAP_EDGES, map_height - _PADDING_FROM_MAP_EDGES - 1)
	
	###### TODO: work for other types of tiles/maps. Maybe parametrize bush/tree values?
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

static func find_empty_isolated_spot(map_width, map_height, object_map, occupied_spots):
	var candidate = null
	var iterations = 0
	
	while true: # returns on success
		candidate = find_empty_spot(map_width, map_height, object_map, occupied_spots)
		var found_spot = true
		
		for item in occupied_spots:
			var distance = sqrt(pow(item[0] - candidate[0], 2) + pow(item[1] - candidate[1], 2))
			if distance < _ISOLATION_DISTANCE_TILES:
				found_spot = false
				break
		
		if found_spot:
			return candidate