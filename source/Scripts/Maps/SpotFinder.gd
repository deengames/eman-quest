extends Node

const TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")

const _PADDING_FROM_MAP_EDGES = 5
const _ISOLATION_DISTANCE_TILES = 10 # n-tile radius

static func find_empty_spot(map_width, map_height, ground_map, object_map, occupied_spots):
	var x = Globals.randint(_PADDING_FROM_MAP_EDGES, map_width - _PADDING_FROM_MAP_EDGES - 1)
	var y = Globals.randint(_PADDING_FROM_MAP_EDGES, map_height - _PADDING_FROM_MAP_EDGES - 1)
	while (
			object_map.get_at(x, y) != null or
			[x, y] in occupied_spots or
			# Trees technically are 2x2 but have empty space around them,
			# so make sure we're not in one of those tiles.
			
			# Also, enemies get stuck on autotiles
			# if they're in the corner, so make sure there's really lots of space.
			# See: https://www.pivotaltracker.com/story/show/162297155
			not is_area_clear(object_map, x - 1, y - 1, x + 1, y + 1)  or
			# current ground tile isn't in walkable_tiles
			not ground_map.get_at(x, y) in Globals.WALKABLE_TILES
		):
			x = Globals.randint(0, map_width - 1)
			y = Globals.randint(0, map_height - 1)
			
	return [x, y]

static func find_empty_isolated_spot(map_width, map_height, object_map, occupied_spots, max_tries = 99999999):
	var candidate = null
	var iterations = 0
	
	# For placing monsters or something. Ground map doesn't matter here. Other checks do.
	var empty_map = TwoDimensionalArray.new(map_width, map_height)
	for y in range(map_height):
		for x in range(map_width):
			empty_map.set_at(x, y, Globals.WALKABLE_TILES[0])
	
	while iterations < max_tries: # returns on success
		candidate = find_empty_spot(map_width, map_height, empty_map, object_map, occupied_spots)

		iterations += 1
		var found_spot = true
		
		for item in occupied_spots:
			var distance = sqrt(pow(item[0] - candidate[0], 2) + pow(item[1] - candidate[1], 2))
			if distance < _ISOLATION_DISTANCE_TILES:
				found_spot = false
				break
		
		if found_spot:
			return candidate

# Inclusive of range
static func is_area_clear(map, start_x, start_y, end_x, end_y):
	for y in range(start_y, end_y + 1):
		for x in range(start_x, end_x + 1):
			if map.get_at(x, y) != null:
				return false
	
	return true