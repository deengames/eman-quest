extends Node

const AreaMap = preload("res://Entities/AreaMap.gd")
const Boss = preload("res://Entities/Battle/Boss.gd")
const EquipmentGenerator = preload("res://Scripts/Generators/EquipmentGenerator.gd")
const KeyItem = preload("res://Entities/KeyItem.gd")
const MapDestination = preload("res://Entities/MapDestination.gd")
const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const SpotFinder = preload("res://Scripts/Maps/SpotFinder.gd")
const StatType = preload("res://Scripts/Enums/StatType.gd")
const TreasureChest = preload("res://Entities/TreasureChest.gd")
const TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")

# Construct a path made up of N points
const NUM_PATH_NODES = 10
# Make sure they're N tiles away from each other
const MINIMUM_NODE_DISTANCE = 5
# Convert this many into wider clearings
const NUM_CLEARINGS = 2
const CLEARING_WIDTH = 7
const CLEARING_HEIGHT = 8

const _BOSS_DATA = {
	"Slime": {
		"type": "Queen Slime",
		"health": 100,
		"strength": 13,
		"defense": 4,
		"turns": 1,
		"experience points": 150,
		
		"skill_probability": 60, # 40 = 40%
		"skills": {
			# These should add up to 100
			"chomp": 80,
			"vampire": 20
		},
	},
	"Frost": {
		"type": "Freeze Fang",
		"health": 300,
		"strength": 30,
		"defense": 5,
		"turns": 1,
		"experience points": 170,
		
		"skill_probability": 50, # 40 = 40%
		"skills": {
			# These should add up to 100
			"chomp": 60, # 20%,
			"freeze": 40
		}
	}
}

const _VARIANT_TILESETS = {
	"Slime": "res://Tilesets/Overworld.tres",
	"Frost": "res://Tilesets/FrostForest.tres"
}

# Sometimes, paths generate right at the bottom of the map, obscuring the entrance
# Add some buffer -- make sure we don't generate paths too low.
const _PATHS_BUFFER_FROM_EDGE = 5
const _MIN_CHESTS = 0
const _MAX_CHESTS = 1
const _MIN_ITEM_POWER = 15
const _MAX_ITEM_POWER = 30

var map_width = 2 * Globals.WORLD_WIDTH_IN_TILES
var map_height = 3 * Globals.WORLD_HEIGHT_IN_TILES

var _clearings_coordinates = []
var _tree_map = []

# Called once per game
func generate(submap, transitions, variation_name):
	var tileset = _VARIANT_TILESETS[variation_name]
	var map = AreaMap.new("Forest", variation_name, tileset, map_width, map_height, submap.area_type)

	var tile_data = self._generate_forest(submap.area_type, transitions) # generates paths too
	self._tree_map = tile_data[1]
	
	map.transitions = transitions
	map.treasure_chests = self._generate_treasure_chests()
	
	if submap.area_type == AreaType.BOSS:
		map.bosses = self._generate_boss(variation_name)
	
	for data in tile_data:
		map.add_tile_data(data)
	
	return map

func _generate_boss(variation_name):
	var coordinates = self._clearings_coordinates[0]
	var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]
	
	var kufi = KeyItem.new()
	kufi.initialize("Bloody Kufi", "A white kufi (skull-cap) stained with blood ...")
	
	var boss = Boss.new()
	boss.initialize(pixel_coordinates[0], pixel_coordinates[1], _BOSS_DATA[variation_name], kufi)
	return { boss.data.type: [boss] }

func _generate_forest(area_type, transitions):
	var to_return = []
	
	var dirt_map = TwoDimensionalArray.new(self.map_width, self.map_height)
	to_return.append(dirt_map)
	self._fill_with("Grass", dirt_map)

	var tree_map = TwoDimensionalArray.new(self.map_width, self.map_height)
	to_return.append(tree_map)
	self._fill_with("Bush", tree_map)

	var path_points = self._generate_paths(transitions, dirt_map, tree_map)
	self._generate_clearings(path_points, dirt_map, tree_map)
	
	self._turn_2x2_bushes_into_trees(tree_map)
	
	return to_return

func _generate_paths(transitions, dirt_map, tree_map):
	var to_generate = NUM_PATH_NODES
	var path_points = []
	var previous = null
	
	while to_generate > 0:
		var x = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_width - _PATHS_BUFFER_FROM_EDGE - 1)
		var y = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_height - _PATHS_BUFFER_FROM_EDGE - 1)
		
		if previous != null and sqrt(pow(x - previous[0], 2) + pow(y - previous[1], 2)) <= MINIMUM_NODE_DISTANCE:
			continue
			
		for node in path_points:
			if sqrt(pow(x - node[0], 2) + pow(y - node[1], 2)) <= MINIMUM_NODE_DISTANCE:
				continue
		
		var current_node = [x, y]
		path_points.append(current_node)
		if previous != null:
			self._generate_path(previous, current_node, dirt_map, tree_map)
		previous = current_node
		to_generate -= 1
	
	# Generate a node close to entrances (5-10 tiles "in" from the entrance).
	# Then, connect entrance => new node => closest path node
	for transition in transitions:
		
		var entrance = [transition.my_position.x, transition.my_position.y]
		var destination = [transition.my_position.x, transition.my_position.y]
		var offset = Globals.randint(5, 10)
		
		if entrance[0] == 0:
			# left entrance
			destination[0] += offset
		elif entrance[0] == map_width - 1:
			# right entrance
			destination[0] -= offset
		elif entrance[1] == 0:
			# top entrance
			destination[1] += offset
		elif entrance[1] == map_height - 1:
			# bottom entrance
			destination[1] -= offset
		
		self._generate_path(entrance, destination, dirt_map, tree_map)
		var closest_node = path_points[0]
		var closest_distance = pow(closest_node[0] - destination[0], 2) + pow(closest_node[1] - destination[1], 2)
		
		for point in path_points:
			var distance = pow(point[0] - destination[0], 2) + pow(point[1] - destination[1], 2)
			if distance < closest_distance:
				closest_node = point
				closest_distance = distance
		
		self._generate_path(destination, closest_node, dirt_map, tree_map)
		
	return path_points

func _generate_path(point1, point2, dirt_map, tree_map):
	var from_x = point1[0]
	var from_y = point1[1]
	
	var to_x = point2[0]
	var to_y = point2[1]
	
	self._convert_to_dirt([from_x, from_y], dirt_map, tree_map)
	
	while from_x != to_x or from_y != to_y:
		# If we're farther away on x-axis, move horizontally.
		if abs(from_x - to_x) > abs(from_y - to_y):
			from_x += sign(to_x - from_x)
		else:
			from_y += sign(to_y - from_y)
			
		self._convert_to_dirt([from_x, from_y], dirt_map, tree_map)
	
func _generate_clearings(path_points, dirt_map, tree_map):
	var clearings_left = NUM_CLEARINGS
	var radius = CLEARING_HEIGHT / 2
	
	while clearings_left > 0:
		var point = path_points[randi() % len(path_points)]
		# Make sure it's not a border one
		var center_x = point[0]
		var center_y = point[1]
		if center_x < CLEARING_WIDTH or center_x > map_width - CLEARING_WIDTH or center_y < CLEARING_HEIGHT or center_y > map_height - CLEARING_HEIGHT:
			continue
			
		self._clearings_coordinates.append(point)
		
		for y in range (center_y - CLEARING_HEIGHT / 2, center_y + CLEARING_HEIGHT / 2):
			for x in range (center_x - CLEARING_WIDTH / 2, center_x + CLEARING_WIDTH / 2):
				# roughly a circle
				if sqrt(pow(x - center_x, 2) + pow(y - center_y, 2)) <= radius:
					self._convert_to_grass([x, y], dirt_map, tree_map)
		
		clearings_left -= 1

func _generate_treasure_chests():
	var num_chests = Globals.randint(_MIN_CHESTS, _MAX_CHESTS)
	var chests = []
	var chests_coordinates = []
	var types = ["weapon", "armour"]
	var stats = {"weapon": StatType.Strength, "armour": StatType.Defense}
	
	while num_chests > 0:
		var spot = SpotFinder.find_empty_spot(map_width, map_height,
			self._tree_map, chests_coordinates)
			
		var type = types[randi() % len(types)]
		var power = Globals.randint(_MIN_ITEM_POWER, _MAX_ITEM_POWER)
		var stat = stats[type]
		var item = EquipmentGenerator.generate(type, stat, power)
		var treasure = TreasureChest.new()
		treasure.initialize(spot[0], spot[1], item)
		chests.append(treasure)
		chests_coordinates.append(spot)
		num_chests -= 1
	
	return chests

func _turn_2x2_bushes_into_trees(tree_map):
	for y in range(0, map_height - 1):
		for x in range(0, map_width - 1):
			if x % 2 == 0 and y % 2 == 0:
				if (tree_map.get(x, y) == "Bush" and 
				tree_map.get(x + 1, y) == "Bush" and
				tree_map.get(x, y + 1) == "Bush" and
				tree_map.get(x + 1, y + 1) == "Bush"):
					tree_map.set(x, y, "Tree")
					tree_map.set(x + 1, y, null)
					tree_map.set(x, y + 1, null)
					tree_map.set(x + 1, y + 1, null)
				

# Almost common with OverworldGenerator
func _fill_with(tile_name, map_array):
	for y in range(0, map_height):
		for x in range(0, map_width):
			map_array.set(x, y, tile_name)

func _convert_to_dirt(position, dirt_map, tree_map):
	self._convert_to(position, true, dirt_map, tree_map)

func _convert_to_grass(position, dirt_map, tree_map):
	self._convert_to(position, false, dirt_map, tree_map)

func _convert_to(position, add_dirt, dirt_map, tree_map):
	# Draws dirt at the specified position. Also clears trees for
	# one tile in all directions surrounding the dirt (kind of like
	# drawing with a 3x3 grass brush around the dirt).
	var x = position[0]
	var y = position[1]
	
	if not add_dirt and dirt_map.get(x, y) != "Dirt":
		dirt_map.set(x, y, "Grass")
	else:
		dirt_map.set(x, y, "Dirt")
	tree_map.set(x, y, null) # remove tree
	
	# Start up, move clockwise
	self._clear_if_tree(tree_map, x, y - 1)
	self._clear_if_tree(tree_map, x + 1, y - 1)
	self._clear_if_tree(tree_map, x + 1, y)
	self._clear_if_tree(tree_map, x + 1, y + 1)
	self._clear_if_tree(tree_map, x, y + 1)
	self._clear_if_tree(tree_map, x - 1, y + 1)
	self._clear_if_tree(tree_map, x - 1, y)
	self._clear_if_tree(tree_map, x - 1, y - 1)

func _clear_if_tree(tree_map, x, y):
	if x >= 0 and x < map_width:
		if y >= 0 and y < map_height:
			if tree_map.get(x, y) != null:
				tree_map.set(x, y, null)

