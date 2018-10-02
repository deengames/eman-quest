extends Node2D

###
# A class that takes an AreaMap and generates the scene (tiles, enemies, etc.)
###

var Boss = preload("res://Entities/Battle/Boss.tscn")
var MapWarp = preload("res://Entities/MapWarp.tscn")
var Monster = preload("res://Entities/Battle/Monster.tscn")
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
	
	var tileset = load(map.tileset_path)
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
	player.position.x = map.entrance_position[0] * Globals.TILE_WIDTH
	player.position.y = map.entrance_position[1] * Globals.TILE_HEIGHT
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
		transition.set_type(destination.map_type)
		transition.position.x = destination.position.x * Globals.TILE_WIDTH
		transition.position.y = destination.position.y * Globals.TILE_HEIGHT
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
	else:
		var generator_path = "res://Scripts/Generators/" + self.map.map_type + "MonsterGenerator.gd"
		if File.new().file_exists(generator_path):
			var type = load(generator_path)
			var generator = type.new()
			monster_data = generator.generate_monsters(self.map)
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

func _populate_treasure_chests():
	for data in self.map.treasure_chests:
		var instance = TreasureChest.instance()
		instance.initialize_from(data)
		self.add_child(instance)
