extends Node

const AreaMap = preload("res://Entities/AreaMap.gd")
const Boss = preload("res://Entities/Battle/Boss.gd")
const EquipmentGenerator = preload("res://Scripts/Generators/EquipmentGenerator.gd")
const KeyItem = preload("res://Entities/KeyItem.gd")
const MapDestination = preload("res://Entities/MapDestination.gd")
const Monster = preload("res://Entities/Battle/Monster.gd")
const StatType = preload("res://Scripts/StatType.gd")
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

# Should be at least 5 so player can level up once
const NUM_MONSTERS = [5, 10]

# Sometimes, paths generate right at the bottom of the map, obscuring the entrance
# Add some buffer -- make sure we don't generate paths too low.
const _PATHS_BUFFER_FROM_EDGE = 5
const _MIN_CHESTS = 2
const _MAX_CHESTS = 3
const _MIN_ITEM_POWER = 15
const _MAX_ITEM_POWER = 30

var map_width = 2 * Globals.WORLD_WIDTH_IN_TILES
var map_height = 3 * Globals.WORLD_HEIGHT_IN_TILES

var entrance_position = [map_width / 2, map_height - 1]
var _back_exit = [map_width / 2, 0]

var _clearings_coordinates = []
var _tree_map = []

# Called once per game
func generate():
	var map = AreaMap.new("Forest", preload("res://Tilesets/Overworld.tres"), self.entrance_position, map_width, map_height, funcref(self, "generate_monsters"))

	var tile_data = self._generate_forest() # generates paths too
	self._tree_map = tile_data[1]
	
	map.transitions = self._generate_transitions()
	map.treasure_chests = self._generate_treasure_chests()
	map.bosses = self._generate_boss()
	
	for data in tile_data:
		map.add_tile_data(data)
	
	# Move entrance up a few tiles so we don't spawn on the exit tile
	entrance_position[1] -= 3
	
	return map

func generate_monsters():
	var monsters = []
	
	for n in Globals.randint(NUM_MONSTERS[0], NUM_MONSTERS[1]) - 1:
		var coordinates = self._find_empty_spot(monsters)
		var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]
		var monster = Monster.new()
		monster.initialize(pixel_coordinates[0], pixel_coordinates[1])
		monsters.append(monster)
	
	# Map of type => array of coordinates (one pair per entity)
	# TODO: return instances of some data type instead. Monster.new()?
	var to_return = { "Slime": monsters }
	return to_return


func _generate_boss():
	var coordinates = self._clearings_coordinates[0]
	var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]
	
	var kufi = KeyItem.new()
	kufi.initialize("Bloody Kufi", "A white kufi (skull-cap) stained with blood ...")
	
	var boss = Boss.new()
	boss.initialize(pixel_coordinates[0], pixel_coordinates[1], kufi)
	return { boss.data.type: [boss] }

func _generate_forest():
	var to_return = []
	
	var dirt_map = TwoDimensionalArray.new(self.map_width, self.map_height)
	to_return.append(dirt_map)
	self._fill_with("Grass", dirt_map)

	var tree_map = TwoDimensionalArray.new(self.map_width, self.map_height)
	to_return.append(tree_map)
	self._fill_with("Bush", tree_map)

	var path_points = self._generate_paths(dirt_map, tree_map)
	self._generate_clearings(path_points, dirt_map, tree_map)
	
	self._turn_2x2_bushes_into_trees(tree_map)
	
	return to_return

func _generate_paths(dirt_map, tree_map):
	var to_generate = NUM_PATH_NODES
	var connect_to = entrance_position
	var path_points = [entrance_position]
	
	# Path goes straight up
	var offset_y_up = Globals.randint(5, 10)
	connect_to = [entrance_position[0], entrance_position[1] - offset_y_up]
	self._generate_path(entrance_position, connect_to, dirt_map, tree_map)

	while to_generate > 0:
		var x = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_width - _PATHS_BUFFER_FROM_EDGE - 1)
		var y = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_height - _PATHS_BUFFER_FROM_EDGE - 1)
		
		if sqrt(pow(x - connect_to[0], 2) + pow(y - connect_to[1], 2)) <= MINIMUM_NODE_DISTANCE:
			continue
			
		for node in path_points:
			if sqrt(pow(x - node[0], 2) + pow(y - node[1], 2)) <= MINIMUM_NODE_DISTANCE:
				continue
		
		var current_node = [x, y]
		self._generate_path(connect_to, current_node, dirt_map, tree_map)
		connect_to = current_node
		path_points.append(current_node)
		to_generate -= 1
	
	# Back entrance/exit
	var back_exit_connector = [self._back_exit[0], offset_y_up] # symmetrical to front
	self._generate_path(path_points[-1], back_exit_connector, dirt_map, tree_map)
	self._generate_path(back_exit_connector, self._back_exit, dirt_map, tree_map)
	
	# Connect to closest node
	var closest_node = path_points[-1]
	var min_distance = sqrt(pow(back_exit_connector[0] - closest_node[0], 2) + pow(back_exit_connector[1] - closest_node[1], 2))
	for node in path_points:
		var distance =  sqrt(pow(back_exit_connector[0] - node[0], 2) + pow(node[1] - closest_node[1], 2))
		if distance < min_distance:
			min_distance = distance
			closest_node = node
	
	self._generate_path(back_exit_connector, closest_node, dirt_map, tree_map)
	
	return path_points

func _generate_transitions():
	var transitions = []
	transitions.append(MapDestination.new("Overworld", Vector2(self.entrance_position[0], self.entrance_position[1])))
	transitions.append(MapDestination.new("Overworld", Vector2(self._back_exit[0], self._back_exit[1])))
	return transitions

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
	var types = ["weapon", "armour"]
	var stats = {"weapon": StatType.Strength, "armour": StatType.Defense}
	
	while num_chests > 0:
		var spot = self._find_empty_spot(chests)
		var type = types[randi() % len(types)]
		var power = Globals.randint(_MIN_ITEM_POWER, _MAX_ITEM_POWER)
		var stat = stats[type]
		var item = EquipmentGenerator.generate(type, stat, power)
		var treasure = TreasureChest.new()
		treasure.initialize(spot[0], spot[1], item)
		chests.append(treasure)
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

func _find_empty_spot(occupied_spots):
	var x = Globals.randint(0, map_width - 1)
	var y = Globals.randint(0, map_height - 1)
	
	while (self._tree_map.get(x, y) == "Bush" or
		[x, y] == self.entrance_position or
		occupied_spots.find([x, y]) > -1 or
		# Trees technically have empty space around them, so make sure
		# we're not in one of those tiles.
		self._tree_map.get(x, y) == "Tree" or
		self._tree_map.get(x - 1, y) == "Tree" or
		self._tree_map.get(x, y - 1) == "Tree" or
		self._tree_map.get(x - 1, y - 1) == "Tree"):
			x = Globals.randint(0, map_width - 1)
			y = Globals.randint(0, map_height - 1)
	
	return [x, y]