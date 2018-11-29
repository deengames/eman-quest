extends Node

const Monster = preload("res://Entities/Battle/Monster.gd")
const SpotFinder = preload("res://Scripts/Maps/SpotFinder.gd")

# Map type => monster => data
const MONSTER_VARIANT_DATA = {
	"River": {
		"Clawomatic": {
			"type": "Clawomatic",
			"weight": 100,
			"health": 100,
			"strength": 1, 
			"defense": 4,
			"turns": 1,
			"experience points": 1,
			
			"skill_probability": 100, # 40 = 40%
			"skills": {
				# These should add up to 100
				"harden": 100 # 20%,
			}
		},
		"WingBeak": {
			"type": "WingBeak",
			"weight": 1,
			"health": 1,
			"strength": 1, 
			"defense": 1,
			"turns": 1,
			"experience points": 1,
			
			"skill_probability": 0, # 40 = 40%
			"skills": {
				# These should add up to 100
			}
		}
	}
}

const NUM_MONSTERS = [45, 60] # May not get this much if we can't find empty spots
const _MAX_EMPTY_SPOT_CHECKS = 1000 # Try 1000 times to find an empty spot. Don't freeze, move on.

func generate_monsters(forest_map):
	var variation = forest_map.variation
	var monsters_data = MONSTER_VARIANT_DATA[variation]
	
	var monsters = { }
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
	for t in forest_map.transitions:
		occupied_spots.append([t.my_position[0], t.my_position[1]])
	
	for n in num_monsters:
		var coordinates = SpotFinder.find_empty_isolated_spot(forest_map.tiles_wide,
			forest_map.tiles_high, forest_map.tile_data[1], occupied_spots, _MAX_EMPTY_SPOT_CHECKS)
		
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