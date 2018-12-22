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
const MonsterGenerator = preload("res://Scripts/Generators/MonsterGenerator.gd")

var map # area map
var _monsters = {} # Type => pixel coordinates of actual monster scenes/entities
var _bosses = {} # Type => pixel coordinates of actual boss scenes/entities
var _restoring_state = false # restoring to previous state after battle

func initialize(map):
	self.map = map

func _ready():
	Globals.current_map = map
	self._restoring_state = Globals.previous_monsters != null
	
	var is_autotiling = "auto:" in map.tileset_path
	var tileset = self._load_tileset_or_auto_tileset(map.tileset_path)
	
	var mapper = TilesetMapper.new(tileset)
	var tile_ids = mapper.load_tileset_mapping()
	var entity_tiles = mapper.get_entity_tiles(map.map_type)
	
	var tilemaps = []
	
	for tilemap_data in map.tile_data:
		var tilemap = TileMap.new()
		tilemaps.append(tilemap)
		tilemap.tile_set = tileset
		tilemap.z_index = -1 # draw under player
		self._populate_tiles(tilemap_data, tilemap, tile_ids, entity_tiles)
	
		# Allow autotiling to take effect
		if is_autotiling:
			tilemap.update_bitmask_region()
		
		self.add_child(tilemap)
	
	self._add_transitions(tilemaps[0], tile_ids)
	self._add_monsters()
	self._populate_treasure_chests()
	
	var player = Player.instance()
	# SceneManagement sets player position correct if back to overworld
	if Globals.transition_used.target_position != null:
		var from = Globals.transition_used
		player.position = Vector2(
			from.target_position.x * Globals.TILE_WIDTH,
			from.target_position.y * Globals.TILE_HEIGHT)
		
	if self._restoring_state == true and not Globals.won_battle:
		player.temporarily_no_battles()
		
	Globals.current_map_scene = self
		
	self.add_child(player)

func get_monsters():
	var to_return = {}
	for type in self._monsters.keys():
		to_return[type] = []
		for monster in self._monsters[type]:
			monster.data_object.x = monster.position.x
			monster.data_object.y = monster.position.y
			to_return[type].append(monster.data_object)
				
	return to_return

func _populate_tiles(tilemap_data, tilemap, tile_ids, entity_tiles):
	for y in range(0, tilemap_data.height):
		for x in range(0, tilemap_data.width):
			var tile_name = tilemap_data.get(x, y)
			
			if tile_name != null:
				tilemap.set_cell(x, y, tile_ids[tile_name])
		
	self._populate_tile_entities(tilemap, entity_tiles)

# Find entities on the map (eg. trees). Remove them and replace them with
# real entities (scenes) so that we can have logic (attach scripts) to them.
func _populate_tile_entities(tile_map, entity_tiles):
	var tile_set = tile_map.tile_set
	for cell in tile_map.get_used_cells():
		var tile_id = tile_map.get_cellv(cell)
		var tile_name = tile_set.tile_get_name(tile_id)
		if entity_tiles.has(tile_name):
			# Spawn + replace with entity of the same name
			var scene = entity_tiles[tile_name]
			var instance = scene.instance()
			tile_map.add_child(instance)
			instance.position.x = cell.x * Globals.TILE_WIDTH
			instance.position.y = cell.y * Globals.TILE_HEIGHT
			# Remove tile
			tile_map.set_cellv(cell, -1)

func _add_transitions(tilemap, tile_ids):
	for destination in map.transitions:
		var warp = MapWarp.instance()
		warp.initialize_from(destination)
		
		# In cases like the Cave, we have special tiles that indicate the exit.
		# If the tileset has such tiles, apply them (after autotiling).
		if destination.direction != null: # null = exit to overworld
			var direction = destination.direction
			var coordinates = destination.my_position
			var exit_type = "Exit" + direction.capitalize()
			
			if tile_ids.has(exit_type):
				tilemap.set_cell(coordinates.x, coordinates.y, tile_ids[exit_type])

		warp.position.x = destination.my_position.x * Globals.TILE_WIDTH
		warp.position.y = destination.my_position.y * Globals.TILE_HEIGHT
		self.add_child(warp)

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
		monster_data = MonsterGenerator.new().generate_monsters(self.map)

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
