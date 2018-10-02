extends Node

const Monster = preload("res://Entities/Battle/Monster.gd")
const SpotFinder = preload("res://Scripts/Maps/SpotFinder.gd")

# Should be at least 5 so player can level up once
const NUM_MONSTERS = [5, 10]

func generate_monsters(forest_map):
	var monsters = []
	var num_monsters = Globals.randint(NUM_MONSTERS[0], NUM_MONSTERS[1])
	
	for n in num_monsters:
		var coordinates = SpotFinder.find_empty_spot(forest_map.tiles_wide,
			forest_map.tiles_high, forest_map.tile_data[1], monsters, forest_map.entrance_position)
		var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]
		var monster = Monster.new()
		monster.initialize(pixel_coordinates[0], pixel_coordinates[1])
		monsters.append(monster)
	
	# Map of type => array of coordinates (one pair per entity)
	# TODO: return instances of some data type instead. Monster.new()?
	var to_return = { "Slime": monsters }
	return to_return