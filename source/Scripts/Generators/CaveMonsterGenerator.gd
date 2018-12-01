extends Node

const Monster = preload("res://Entities/Battle/Monster.gd")
const SpotFinder = preload("res://Scripts/Maps/SpotFinder.gd")

# Map type => monster => data
const MONSTER_VARIANT_DATA = {
	"River": {
		"Clawomatic": {
			"type": "Clawomatic",
			"weight": 50,
			"health": 150,
			"strength": 30,
			"defense": 10,
			"turns": 1,
			"experience points": 18,
			
			"skill_probability": 50, # 40 = 40%
			"skills": {
				"harden": 100 
			}
		},
		"WingBeak": {
			"type": "WingBeak",
			"weight": 50,
			"health": 110,
			"strength": 20,
			"defense": 16,
			"turns": 1,
			"experience points": 16,
			
			"skill_probability": 50, # 40 = 40%
			"skills": {
				"roar": 100 
			}
		}
	},
	"Lava": {
		"Flame Tail": {
			"type": "Flame Tail",
			"weight": 60,
			"health": 110,
			"strength": 35,
			"defense": 10,
			"turns": 1,
			"experience points": 13,
			
			"skill_probability": 30, # 40 = 40%
			"skills": {
				"poison": 100 
			}
		},
		"Red Scorpion": {
			"type": "Red Scorpion",
			"weight": 40,
			"health": 80,
			"strength": 25,
			"defense": 17,
			"turns": 1,
			"experience points": 13,
			
			"skill_probability": 25,
			"skills": {
				"armour break": 100
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