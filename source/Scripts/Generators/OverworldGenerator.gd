extends Node

var AreaMap = preload("res://Entities/AreaMap.gd")
var AreaType = preload("res://Scripts/Enums/AreaType.gd")
var MapDestination = preload("res://Entities/MapDestination.gd")
var TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")

# Don't place things N tiles from the edges of the map
const _PADDING_FROM_SIDES_OF_MAP = 4
const _TRANSITION_DESTINATIONS = ["Forest", "Cave", "Final"]

var map_width = Globals.WORLD_WIDTH_IN_TILES
var map_height = Globals.WORLD_HEIGHT_IN_TILES

func generate():
	var map = AreaMap.new("Overworld", null, "res://Tilesets/Overworld.tres", map_width, map_height, null)
	
	var tile_data = self._generate_world_map()
	map.add_tile_data(tile_data)
	
	self._place_area_entrances(map)
	return map

func _generate_world_map():
	
	var to_return = TwoDimensionalArray.new(map_width, map_height)
	self._fill_with_grass(to_return)
	
	var last_river_coordinates = self._create_river(to_return)
	self._create_lake(to_return, last_river_coordinates)
	
	return to_return

func _fill_with_grass(map):
	for y in range(0, Globals.WORLD_HEIGHT_IN_TILES):
		for x in range(0, Globals.WORLD_WIDTH_IN_TILES):
			map.set(x, y, "Grass")

# Returns the [x, y] of the last tile in the river (farthest from the edge of the map)
func _create_river(map):
	var direction = Globals.randint(1, 4) # clockwise rotation starting with up
	
	var last_x = 0
	var last_y = 0
	
	if direction == 1 or direction == 3:
		var x = Globals.randint(Globals.WORLD_WIDTH_IN_TILES / 3, 2 * Globals.WORLD_WIDTH_IN_TILES / 3)
		var start_y = 0
		var stop_y = Globals.randint(Globals.WORLD_HEIGHT_IN_TILES / 4, Globals.WORLD_HEIGHT_IN_TILES / 3)
		
		last_x = x
		last_y = stop_y
		
		if direction == 3: # down
			start_y = stop_y
			stop_y = Globals.WORLD_HEIGHT_IN_TILES
		for y in range(start_y, stop_y):
			map.set(x, y, "Water")
			
	else: #if direction == 2 or direction == 4:
		var y = Globals.randint(Globals.WORLD_HEIGHT_IN_TILES / 3, 2 * Globals.WORLD_HEIGHT_IN_TILES / 3)
		var start_x = 0
		var stop_x = Globals.randint(Globals.WORLD_WIDTH_IN_TILES / 4, Globals.WORLD_WIDTH_IN_TILES / 2)
		
		last_x = stop_x
		last_y = y
		
		if direction == 2: # right
			start_x = stop_x
			stop_x = Globals.WORLD_WIDTH_IN_TILES
			
		for x in range(start_x, stop_x):
			map.set(x, y, "Water")
	
	return [last_x, last_y]

func _create_lake(map, lake_coordinates):
	var lake_x = lake_coordinates[0]
	var lake_y = lake_coordinates[1]
	# Creates a 3x3 lake. End of range is exclusive, so add another +1
	for y in range(lake_y - 1, lake_y + 2):
		for x in range (lake_x - 1, lake_x + 2):
			map.set(x, y, "Water")

func _place_area_entrances(map):
	var placed_areas = []
	var ground_tiles = map.tile_data[0]
	
	for destination in self._TRANSITION_DESTINATIONS:
		var coordinates = self._find_empty_area(ground_tiles, placed_areas)
		# TODO: make sure it's not near any other placed areas
		placed_areas.append(coordinates)
		
		 # Maps have a start map with an entrance. Find it.
		var target_destination = Vector2(0, 0)
		# Not true for Final map, which has a hard-coded entrance.
		if Globals.maps.has(destination):
			var maps = Globals.maps[destination]
			for submap in maps:
				if submap.area_type == AreaType.ENTRANCE:
					target_destination = submap.entrance_from_overworld
					break
					
		map.transitions.append(MapDestination.new(coordinates, destination, target_destination, null))

func _find_empty_area(tile_data, placed_areas):
	var x = Globals.randint(_PADDING_FROM_SIDES_OF_MAP, map_width - 1 - _PADDING_FROM_SIDES_OF_MAP)
	var y = Globals.randint(_PADDING_FROM_SIDES_OF_MAP, map_height - 1 - _PADDING_FROM_SIDES_OF_MAP)
	
	while not self._is_area_around_tile_valid_and_empty(tile_data, placed_areas, x, y):
		x = Globals.randint(_PADDING_FROM_SIDES_OF_MAP, map_width - 1 - _PADDING_FROM_SIDES_OF_MAP)
		y = Globals.randint(_PADDING_FROM_SIDES_OF_MAP, map_height - 1 - _PADDING_FROM_SIDES_OF_MAP)
	
	return Vector2(x, y)
	
func _is_area_around_tile_valid_and_empty(tile_data, placed_areas, x, y):
	return (_is_tile_valid_and_empty(tile_data, placed_areas, x - 1, y - 1) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x, y - 1) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x + 1, y - 1) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x + 1, y) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x + 1, y + 1) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x, y + 1) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x - 1, y + 1) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x - 1, y) and
		_is_tile_valid_and_empty(tile_data, placed_areas, x, y))

func _is_tile_valid_and_empty(tile_data, placed_areas, x, y):
	# Don't be on the border of the map
	var is_on_map = x > 0 and x < map_width - 1 and y > 0 and y < map_height - 1
	var is_empty = tile_data.get(x, y) == "Grass" and placed_areas.find([x, y]) == -1
	return  is_on_map and is_empty