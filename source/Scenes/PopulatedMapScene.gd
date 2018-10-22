extends Node2D

###
# A class that takes an AreaMap and generates the scene (tiles, enemies, etc.)
###

const AutoTileTilesets = preload("res://Tilesets/AutoTileTilesets.tscn")
const Boss = preload("res://Entities/Battle/Boss.tscn")
const MapWarp = preload("res://Entities/MapWarp.tscn")
const Monster = preload("res://Entities/Battle/Monster.tscn")
const Player = preload("res://Entities/Player.tscn")
const TreasureChest = preload("res://Entities/TreasureChest.tscn")
const TilesetMapper = preload("res://Scripts/TilesetMapper.gd")

var map # area map
var _monsters = {} # Type => pixel coordinates of actual monster scenes/entities
var _bosses = {} # Type => pixel coordinates of actual boss scenes/entities
var _restoring_state = false # restoring to previous state after battle

func initialize(map):
	self.map = map

func _ready():
	Globals.current_map = map
	self._restoring_state = Globals.previous_monsters != null
	
	var tileset = self._load_tileset_or_auto_tileset(map.tileset_path)
	var tile_ids = TilesetMapper.new().load_tileset_mapping(tileset)
	
	var i = 0
	
	for tilemap_data in map.tile_data:
		# TODO: where does this block go?
		var tilemap = TileMap.new()
		tilemap.tile_set = tileset
		tilemap.z_index = i - len(map.tile_data) # draw under player
		self._populate_tiles(tilemap_data, tilemap, tile_ids)
		self.add_child(tilemap)
	
	self._add_transitions()
	self._add_monsters()
	self._populate_treasure_chests()
	
	var player = Player.instance()
	# SceneManagement sets player position correct if back to overworld
	if map.map_type != "Overworld":
		var from = Globals.transition_used
		player.position = Vector2(
			from.target_position.x * Globals.TILE_WIDTH,
			from.target_position.y * Globals.TILE_HEIGHT)
	
		# Offset so we don't spawn directly on a transition
		if from.direction == "up" or from.target_position.y >= self.map.tiles_high - 1:
			player.position.y -= 2 * Globals.TILE_HEIGHT
		elif from.direction == "left" or from.target_position.x >= self.map.tiles_wide - 1:
			player.position.x -= 2 * Globals.TILE_WIDTH
		
	if self._restoring_state == true and not Globals.won_battle:
		player.temporarily_no_battles()
		
	self.add_child(player)
	
	Globals.current_map_scene = self

func get_monsters():
	var to_return = {}
	for type in self._monsters.keys():
		to_return[type] = []
		for monster in self._monsters[type]:
			monster.data_object.x = monster.position.x
			monster.data_object.y = monster.position.y
			to_return[type].append(monster.data_object)
				
	return to_return

func _populate_tiles(tilemap_data, tilemap, tile_ids):
	for y in range(0, tilemap_data.height):
		for x in range(0, tilemap_data.width):
			var tile_name = tilemap_data.get(x, y)
			if tile_name != null:
				tilemap.set_cell(x, y, tile_ids[tile_name])

func _add_transitions():
	for destination in map.transitions:
		var transition = MapWarp.instance()
		transition.initialize_from(destination)
		transition.position.x = destination.my_position.x * Globals.TILE_WIDTH
		transition.position.y = destination.my_position.y * Globals.TILE_HEIGHT
		self.add_child(transition)

func _add_monsters():
	var monster_data = {}
	
	# We came back to this map after battle. Restore monster state.
	if self._restoring_state:
		# Usual array of monster_type => list of pixel coordianates.
		monster_data = Globals.previous_monsters
		
		# Remove the monster we just vanquished
		if Globals.won_battle:
			# Monsters, not bosses, go in monster_data
			if Globals.current_monster_type in monster_data:
				var monsters = monster_data[Globals.current_monster_type]
				monsters.remove(monsters.find(Globals.current_monster))
			elif Globals.current_monster.IS_BOSS:
				Globals.current_monster.is_alive = false
			
		Globals.current_monster = null
		Globals.previous_monsters = null
	elif self.map.monsters.size() > 0:
		# We loaded a save game. Load those exact same monsters.
		monster_data = self.map.monsters
	else:
		var generator_path = "res://Scripts/Generators/" + self.map.map_type + "MonsterGenerator.gd"
		if File.new().file_exists(generator_path):
			var type = load(generator_path)
			var generator = type.new()
			monster_data = {}#generator.generate_monsters(self.map)
		else:
			monster_data = {}
	
	self._monsters = {}
	self._bosses = {}
	
	for monster_type in monster_data.keys():
		var monsters = monster_data[monster_type]
		var instances = []
		
		for monster in monsters:
			var instance = Monster.instance()
			instance.initialize_from(monster)
			self.add_child(instance)
			instances.append(instance)
		
		self._monsters[monster_type] = instances
	
	for boss_type in map.bosses.keys():
		var bosses = []
		for boss in map.bosses[boss_type]:
			if boss.is_alive:
				var instance = Boss.instance()
				instance.initialize_from(boss)
				self.add_child(instance)
				bosses.append(instance)
				
		self._bosses[boss_type] = bosses
	
	# Persist on save
	map.monsters = self._monsters

func _populate_treasure_chests():
	for data in self.map.treasure_chests:
		var instance = TreasureChest.instance()
		instance.initialize_from(data)
		self.add_child(instance)

# Returns a tileset.
# Given a path, it may be a regular tileset resource path,
# eg. res://Tilesets/FrostForest.tres
# OR, it may be our custom-made auto-tileset path, eg. auto:RiverCave.
# If it's the latter, load the AutoTileTilesets scene; this scene has
# one tilemap per tileset (named with the tileset, eg. RiverCave).
# Take the tileset from this tilemap, because it's configured with autotiles.
func _load_tileset_or_auto_tileset(tileset_path):
	if "auto:" in tileset_path:
		var layer_name = tileset_path.replace("auto:", "")
		var auto_tilesets = AutoTileTilesets.instance()
		var tilemap = auto_tilesets.get_node(layer_name)
		var tileset = tilemap.tile_set
		return tileset
	else:
		return load(tileset_path)