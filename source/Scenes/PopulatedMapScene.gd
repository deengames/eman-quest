extends Node2D

###
# A class that takes an AreaMap and generates the scene (tiles, enemies, etc.)
###

var MapWarp = preload("res://Entities/MapWarp.tscn")
const Player = preload("res://Entities/Player.tscn")
const TilesetMapper = preload("res://Scripts/TilesetMapper.gd")

var map # area map
var _monsters = {} # Type => pixel coordinates of actual monster scenes/entities
var _restoring_state = false # restoring to previous state after battle

func _init(map):
	self.map = map

func _ready():
	Globals.current_map = map
	self._restoring_state = Globals.previous_monsters != null
	
	var tileset = map.tileset
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
	
	var player = Player.instance()
	player.position.x = map.entrance_position[0] * Globals.TILE_WIDTH
	player.position.y = map.entrance_position[1] * Globals.TILE_HEIGHT
	if self._restoring_state == true and not Globals.won_battle:
		player.temporarily_no_battles()
	self.add_child(player)
	
	Globals.current_map_scene = self
	
func _populate_tiles(tilemap_data, tilemap, tile_ids):
	for y in range(0, tilemap_data.height):
		for x in range(0, tilemap_data.width):
			var tile_name = tilemap_data.get(x, y)
			if tile_name != null:
				tilemap.set_cell(x, y, tile_ids[tile_name])

func _add_transitions():
	for map_type in map.transitions.keys():
		var map_coordinates = map.transitions[map_type]
		var transition = MapWarp.instance()
		transition.map_type = map_type
		transition.position.x = map_coordinates[0] * Globals.TILE_WIDTH
		transition.position.y = map_coordinates[1] * Globals.TILE_HEIGHT
		self.add_child(transition)

func _add_monsters():
	var monster_data = {}
	
	# We came back to this map after battle. Restore monster state.
	if self._restoring_state:
		# Usual array of monster_type => list of pixel coordianates.
		monster_data = Globals.previous_monsters
		
		# Remove the monster we just vanquished
		if Globals.won_battle:
			var monsters = monster_data[Globals.current_monster_type]
			monsters.remove(monsters.find(Globals.current_monster))
			
		Globals.current_monster = null
		Globals.previous_monsters = null
	else:
		monster_data = map.generate_monsters()
	
	self._monsters = {}
	for monster_type in monster_data.keys():
		var class_type = load("res://Entities/Monsters/" + monster_type + ".tscn")
		var coordinate_pairs = monster_data[monster_type]
		var monsters = []
		
		for coordinates in coordinate_pairs:
			var instance = class_type.instance()
			instance.position.x = coordinates[0]
			instance.position.y = coordinates[1]
			self.add_child(instance)
			monsters.append(instance)
		
		self._monsters[monster_type] = monsters

func get_monsters():
	# Return pixel coordinates for all live instances
	var to_return = {}
	for type in self._monsters.keys():
		to_return[type] = []
		for monster in self._monsters[type]:
			to_return[type].append([monster.position.x, monster.position.y])
	
	return to_return