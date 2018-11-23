extends Node

const TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")

const _PADDING_FROM_MAP_EDGES = 5
const _ISOLATION_DISTANCE_TILES = 10 # n-tile radius

static func find_empty_spot(map_width, map_height, ground_map, object_map, walkable_tiles, occupied_spots):
	var x = Globals.randint(_PADDING_FROM_MAP_EDGES, map_width - _PADDING_FROM_MAP_EDGES - 1)
	var y = Globals.randint(_PADDING_FROM_MAP_EDGES, map_height - _PADDING_FROM_MAP_EDGES - 1)
	var debug = null
	
	while (object_map.get(x, y) != null or
		occupied_spots.find([x, y]) > -1 or
		# Trees technically have empty space around them, so make sure
		# we're not in one of those tiles.
		object_map.get(x, y) != null or
		object_map.get(x - 1, y) != null or
		object_map.get(x, y - 1) != null or
		object_map.get(x - 1, y - 1) != null or
		# current ground tile isn't in walkable_tiles
		walkable_tiles.find(ground_map.get(x, y)) == -1):
			x = Globals.randint(0, map_width - 1)
			y = Globals.randint(0, map_height - 1)
			
			debug = ground_map.get(x, y)
			print("D="+str(debug) + " MAP=" + str(ground_map.get(x, y)))
			print("O="+str(object_map.get(x, y)))
			print("O1="+str(object_map.get(x - 1, y)))
			print("O2="+str(object_map.get(x, y - 1)))
			print("O3="+str(object_map.get(x - 1, y - 1)))
			print("C="+str(occupied_spots.find([x, y])))
			print("W="+str(walkable_tiles.find(ground_map.get(x, y))))
			pass
	
	return [x, y]

static func find_empty_isolated_spot(map_width, map_height, object_map, occupied_spots, max_tries = 99999999):
	var candidate = null
	var iterations = 0
	var empty_map = TwoDimensionalArray.new(map_width, map_height)
	
	while iterations < max_tries: # returns on success
		# Asking for all the params we pass in to find_empty_spot is madness. We don't need them.
		# Instead, just create/fake stuff. Like an empty ground map, and passing [null] allows
		# the check of "null in [null]" when get(x, y) is null (empty map).
		candidate = find_empty_spot(map_width, map_height, empty_map, object_map, [null], occupied_spots)

		iterations += 1
		var found_spot = true
		
		for item in occupied_spots:
			var distance = sqrt(pow(item[0] - candidate[0], 2) + pow(item[1] - candidate[1], 2))
			if distance < _ISOLATION_DISTANCE_TILES:
				found_spot = false
				break
		
		if found_spot:
			return candidate