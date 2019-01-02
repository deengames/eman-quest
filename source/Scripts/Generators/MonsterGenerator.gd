extends Node

const Monster = preload("res://Entities/Battle/Monster.gd")
const SpotFinder = preload("res://Scripts/Maps/SpotFinder.gd")

const MONSTER_DATA = preload("res://Data/MonsterData.gd").MONSTER_DATA

const NUM_MONSTERS = [4, 5] # May not get this much if we can't find empty spots
const _MAX_EMPTY_SPOT_CHECKS = 1000 # Try 1000 times to find an empty spot. Don't freeze, move on.

func generate_monsters(map):
	var monsters = {}
	
	var map_type = map.map_type
	var variation = map.variation
	
	if map_type in MONSTER_DATA:
		var variations = MONSTER_DATA[map_type]
		if variation in variations:
			var monsters_data = MONSTER_DATA[map_type][variation]
		
			var total_weight = 0
			# if slime has a weight of three and bat has a weight of two, this array
			# contains: slime, slime, slime, bat, bat. Then select a random item, done.
			var weighted_monsters_array = []
		
			for type in monsters_data.keys():
				monsters[type] = []
				var monster_weight = monsters_data[type]["weight"]
				for i in range(monster_weight):
					weighted_monsters_array.append(type)
		
			var num_monsters = Globals.randint(NUM_MONSTERS[0], NUM_MONSTERS[1])
		
			var occupied_spots = []
			for t in map.transitions:
				occupied_spots.append([t.my_position[0], t.my_position[1]])
		
			for n in num_monsters:
				var coordinates = SpotFinder.find_empty_isolated_spot(map.tiles_wide,
					map.tiles_high, map.tile_data[1], occupied_spots, _MAX_EMPTY_SPOT_CHECKS)
		
				if coordinates != null: # found a spot?
					var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]
					var monster = Monster.new()
					monster.initialize(pixel_coordinates[0], pixel_coordinates[1])
					occupied_spots.append(coordinates)
		
					var type = weighted_monsters_array[randi() % len(weighted_monsters_array)]
					monster.data = monsters_data[type]
					monsters[type].append(monster)

	# Map of type => array of coordinates (one pair per entity)
	# TODO: return instances of some data type instead. Monster.new()?
	return monsters