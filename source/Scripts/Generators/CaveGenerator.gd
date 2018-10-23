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

const _BOSS_DATA = {
	"River": {
	}
}

const _VARIANT_TILESETS = {
	"River": "auto:RiverCave",
}

const _WATER_DECORATION_TILE_CHOICES = ["WaterRock1", "WaterRock2", "WaterRock3", "WaterRock4"]
const _GROUND_DECORATION_TILE_CHOICES = ["Pebbles1", "Pebbles2", "Pebbles3"]

# Number of "open" floor cells as a percentage of our area
const _FLOOR_TILES_PERCENTAGE = 25

const _PATHS_BUFFER_FROM_EDGE = 3
const _NUM_CHESTS = [0, 1]
const _ITEM_POWER = [30, 50]
const _WALL_DECORATION_TILES = 150
const _GROUND_DECORATION_TILES_PERCENT = 5 # X% of floor tiles are decoration

var map_width = 3 * Globals.WORLD_WIDTH_IN_TILES
var map_height = 4 * Globals.WORLD_HEIGHT_IN_TILES

# Mostly a SINGLE TILEMAP. You can't have an autotiled ground, and superimpose
# a non-autotiled water map on top. It shows the ground through, which
# is correctly not auto-tiled
var _ground_tilemap = null

# Called once per game
func generate(submap, transitions, variation_name):
	var tileset = _VARIANT_TILESETS[variation_name]
	var map = AreaMap.new("Cave", variation_name, tileset, map_width, map_height, submap.area_type)

	var tile_data = self._generate_cave(submap.area_type, transitions) # generates paths too

	map.transitions = transitions
	map.treasure_chests = self._generate_treasure_chests()

	# TODO: generate boss
	#if submap.area_type == AreaType.BOSS:
	#	map.bosses = self._generate_boss(variation_name)

	for data in tile_data:
		map.add_tile_data(data)

	return map

func _generate_boss(variation_name):
	# TODO: place boss
	var coordinates = [0, 0] # self._clearings_coordinates[0]
	var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]

	#var kufi = KeyItem.new()
	#kufi.initialize("Bloody Kufi", "A white kufi (skull-cap) stained with blood ...")

	var boss = Boss.new()
	boss.initialize(pixel_coordinates[0], pixel_coordinates[1], _BOSS_DATA[variation_name], null)
	return { boss.data.type: [boss] }

func _generate_cave(area_type, transitions):
	var to_return = []

	self._ground_tilemap = TwoDimensionalArray.new(self.map_width, self.map_height)
	to_return.append(self._ground_tilemap)
	self._fill_with("Water", self._ground_tilemap)
	
	var decoration_tilemap = TwoDimensionalArray.new(self.map_width, self.map_height)
	to_return.append(decoration_tilemap)
	
	self._generate_tiles(transitions)
	self._generate_decoration_tiles(decoration_tilemap)

	return to_return

func _generate_tiles(transitions):
	
	var floors_to_create = floor(self.map_width * self.map_height * _FLOOR_TILES_PERCENTAGE / 100)
	
	var current_x = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_width - _PATHS_BUFFER_FROM_EDGE - 1)
	var current_y = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_height - _PATHS_BUFFER_FROM_EDGE - 1)
	var created_ground = []
	
	while floors_to_create > 0:
		if self._ground_tilemap.get(current_x, current_y) != "Ground":
			self._convert_to_dirt([current_x, current_y])
			created_ground.append([current_x, current_y])
			floors_to_create -= 1
			
		var new_coordinates = self._pick_random_adjacent_tile(current_x, current_y)
		current_x = new_coordinates[0]
		current_y = new_coordinates[1]
		
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

		self._generate_path(entrance, destination)
		var closest_node = self._find_closest_cell_to(destination, created_ground)
		self._generate_path(destination, closest_node)

func _find_closest_cell_to(point, candidates):
	var closest_cell = null
	var closest_distance = null
	
	for candidate in candidates:
		var x = candidate[0]
		var y = candidate[1]
		
		var distance = pow(point[0] - x, 2) + pow(point[1] - y, 2)
		if closest_distance == null or distance < closest_distance:
			closest_cell = [x, y]
			closest_distance = distance
		
	return closest_cell
	
func _generate_path(point1, point2):
	var from_x = point1[0]
	var from_y = point1[1]

	var to_x = point2[0]
	var to_y = point2[1]

	self._convert_to_dirt([from_x, from_y])

	while from_x != to_x or from_y != to_y:
		# If we're farther away on x-axis, move horizontally.
		if abs(from_x - to_x) > abs(from_y - to_y):
			from_x += sign(to_x - from_x)
		else:
			from_y += sign(to_y - from_y)

		self._convert_to_dirt([from_x, from_y])

func _generate_treasure_chests():
	var num_chests = Globals.randint(_NUM_CHESTS[0], _NUM_CHESTS[1])
	var chests = []
	var chests_coordinates = []
	var types = ["weapon", "armour"]
	var stats = {"weapon": StatType.Strength, "armour": StatType.Defense}

	while num_chests > 0:
		var spot = SpotFinder.find_empty_spot(map_width, map_height,
			self._ground_tilemap, chests_coordinates)

		var type = types[randi() % len(types)]
		var power = Globals.randint(_ITEM_POWER[0], _ITEM_POWER[1])
		var stat = stats[type]
		var item = EquipmentGenerator.generate(type, stat, power)
		var treasure = TreasureChest.new()
		treasure.initialize(spot[0], spot[1], item)
		chests.append(treasure)
		chests_coordinates.append(spot)
		num_chests -= 1

	return chests

func _pick_random_adjacent_tile(x, y):
	var to_return = []
	
	if x > _PATHS_BUFFER_FROM_EDGE:
		to_return.append([x - 1, y])
	if x < map_width - _PATHS_BUFFER_FROM_EDGE - 1:
		to_return.append([x + 1, y])
	if y > _PATHS_BUFFER_FROM_EDGE:
		to_return.append([x, y - 1])
	if y < map_height - _PATHS_BUFFER_FROM_EDGE - 1:
		to_return.append([x, y + 1])
		
	return to_return[randi() % len(to_return)]

func _generate_decoration_tiles(decoration_tilemap):
	self._decorate_water(decoration_tilemap)
	self._decorate_ground(decoration_tilemap)

# Adds random rocks into the river
func _decorate_water(decoration_tilemap):
	for i in range(_WALL_DECORATION_TILES):
		var x = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_width - _PATHS_BUFFER_FROM_EDGE - 1)
		var y = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_height - _PATHS_BUFFER_FROM_EDGE - 1)
		
		# Add the rock to a center of a 3x3 square of water. This plays nicely with autotiles.
		if (self._ground_tilemap.get(x, y) == "Water" and self._ground_tilemap.get(x, y - 1) == "Water" and
			self._ground_tilemap.get(x + 1, y - 1) == "Water" and self._ground_tilemap.get(x + 1, y) == "Water" and
			self._ground_tilemap.get(x + 1, y + 1) == "Water" and self._ground_tilemap.get(x, y + 1) == "Water" and
			self._ground_tilemap.get(x - 1, y + 1) == "Water" and self._ground_tilemap.get(x - 1, y) == "Water" and
			self._ground_tilemap.get(x - 1, y - 1) == "Water"):
				
				var tile = _WATER_DECORATION_TILE_CHOICES[randi() % len(_WATER_DECORATION_TILE_CHOICES)]
				decoration_tilemap.set(x, y, tile)

# Adds random rocks into the river
func _decorate_ground(decoration_tilemap):
	for i in range(_WALL_DECORATION_TILES):
		var x = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_width - _PATHS_BUFFER_FROM_EDGE - 1)
		var y = Globals.randint(_PATHS_BUFFER_FROM_EDGE, map_height - _PATHS_BUFFER_FROM_EDGE - 1)
		
		# Add the rock to a center of a 3x3 square of ground. This plays nicely with autotiles.
		if (self._ground_tilemap.get(x, y) == "Ground" and self._ground_tilemap.get(x, y - 1) == "Ground" and
			self._ground_tilemap.get(x + 1, y - 1) == "Ground" and self._ground_tilemap.get(x + 1, y) == "Ground" and
			self._ground_tilemap.get(x + 1, y + 1) == "Ground" and self._ground_tilemap.get(x, y + 1) == "Ground" and
			self._ground_tilemap.get(x - 1, y + 1) == "Ground" and self._ground_tilemap.get(x - 1, y) == "Ground" and
			self._ground_tilemap.get(x - 1, y - 1) == "Ground"):
				
				var tile = _GROUND_DECORATION_TILE_CHOICES[randi() % len(_GROUND_DECORATION_TILE_CHOICES)]
				decoration_tilemap.set(x, y, tile)

############# TODO: DRY
# Almost common with OverworldGenerator
func _fill_with(tile_name, map_array):
	for y in range(0, map_height):
		for x in range(0, map_width):
			map_array.set(x, y, tile_name)

func _convert_to_dirt(position):
	self._convert_to(position)
	self._convert_to([position[0] + 1, position[1]])
	self._convert_to([position[0], position[1] + 1])
	self._convert_to([position[0] + 1, position[1] + 1])

func _convert_to(position):
	# Draws dirt at the specified position. Also clears trees for
	# one tile in all directions surrounding the dirt (kind of like
	# drawing with a 3x3 grass brush around the dirt).
	var x = position[0]
	var y = position[1]

	if x >= 0 and x < map_width and y >= 0 and y < map_height:
		self._ground_tilemap.set(x, y, "Ground")
