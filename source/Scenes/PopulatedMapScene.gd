extends Node2D

###
# A class that takes an AreaMap and generates the scene (tiles, enemies, etc.)
###

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")
const AudioManager = preload("res://Scripts/AudioManager.gd")
const AutoTileTilesets = preload("res://Tilesets/AutoTileTilesets.tscn")
const Boss = preload("res://Entities/Battle/Boss.tscn")
const MapWarp = preload("res://Entities/MapWarp.tscn")
const MapWarpScript = preload("res://Entities/MapWarp.gd")
const Monster = preload("res://Entities/Battle/Monster.tscn")
const MonsterGenerator = preload("res://Scripts/Generators/MonsterGenerator.gd")
const Player = preload("res://Entities/Player.tscn")
const Quest = preload("res://Entities/Quest.gd")
const SaveManager = preload("res://Scripts/SaveManager.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const TreasureChest = preload("res://Entities/TreasureChest.tscn")
const TilesetMapper = preload("res://Scripts/TilesetMapper.gd")

const _NPC_MAX_DISTANCE_TO_BOSS = 5

var map # area map
# for testing
var play_audio = true

# Type => pixel coordinates of actual monster scenes/entities
# In add_monsters, transmuated into type => scenes/entities
var _monsters = {}
var _bosses = {} # Type => pixel coordinates of actual boss scenes/entities
var _restoring_state = false # restoring to previous state after battle
var _audio_bgs # AudioManager

var _total_time = 0
var _should_autosave = true # false after boss battles

func initialize(map):
	self.map = map

func _ready():
	Globals.current_map = map
	Globals.current_map_type = map.map_type
	self._restoring_state = Globals.previous_monsters != null
	
	var is_autotiling = "auto:" in map.tileset_path
	var tileset = self._load_tileset_or_auto_tileset(map.tileset_path)
	
	var mapper = TilesetMapper.new(tileset)
	var tile_ids = mapper.load_tileset_mapping()
	var entity_tiles = mapper.get_entity_tiles(map.map_type, map.variation)

	if self.play_audio:
		self._audio_bgs = AudioManager.new()
		
		if map != null and map.map_type != null and map.variation != null:
			var bgs_key = map.variation.to_lower() + "-" + map.map_type.to_lower() + "-bgs"
			if self._audio_bgs.audio_clips.has(bgs_key):
				self._audio_bgs.play_sound(bgs_key)
	
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
	var player_position
	var transitions = []
	
	# SceneManagement sets player position correct if back to overworld
	if Globals.transition_used != null and Globals.transition_used.target_position != null:
		var from = Globals.transition_used
		
		# For calculations on walkability just one step below, for some reason, Y is off by -1
		# Offsetting by +1 here, makes everything work (below in walkable/transition checks)
		player_position = Vector2(from.target_position.x, from.target_position.y + 1)
		
		# Now that we barricaded map exists with transitions, make sure the player
		# doesn't spawn on one. Find transitions around us and step away.
		# If you check a plus-shape set of tiles around us, only one is on the map
		# and not a transition.
		
		for child in get_children():
			if child is MapWarpScript:
				transitions.append(Vector2(child.position.x / Globals.TILE_WIDTH, child.position.y / Globals.TILE_HEIGHT))
				
	# Not sure why this is null on load game. Hmm.
	if player_position != null:
		# NB: this fails if MapWarp radius is exactly 32 and the map entrance is at the bottom.
		# Everything works correctly, except the map warp directly under the player triggers.
		# A threshold radius of ~7px (25px radius map warps) seems to avoid the problem.
		# If it becomes too small, we can walk through the middle of two exits sometimes, which is a no-no.
		if _is_walkable_and_no_transitions(player_position, transitions):
			player_position = player_position
		elif _is_walkable_and_no_transitions(Vector2(player_position.x - 1, player_position.y), transitions):
			player_position = Vector2(player_position.x - 1, player_position.y)
		elif _is_walkable_and_no_transitions(Vector2(player_position.x + 1, player_position.y), transitions):
			player_position = Vector2(player_position.x + 1, player_position.y)
		elif _is_walkable_and_no_transitions(Vector2(player_position.x, player_position.y - 1), transitions):
			player_position = Vector2(player_position.x, player_position.y - 1)
		elif _is_walkable_and_no_transitions(Vector2(player_position.x, player_position.y + 1), transitions):
			player_position = Vector2(player_position.x, player_position.y + 1)
			
		player.position = Vector2(
			player_position.x * Globals.TILE_WIDTH,
			player_position.y * Globals.TILE_HEIGHT)
		
	if self._restoring_state == true and not Globals.won_battle:
		# Probably reduundant because we now also set this in BattleResultsWindow.gd
		player.temporarily_no_battles()
		
	Globals.current_map_scene = self
	
	#########
	# https://www.pivotaltracker.com/story/show/163181477
	# https://www.pivotaltracker.com/story/show/162750314
	# Worst. Bug. Ever. SOMETIMES, in ONE particular cave map,
	# switching maps teleported you ~4 spaces up, at some point
	# between Player._init and Player._process. Debugged, no dice.
	# SO, we do something terrible: we freeze the player here, set
	# Globals.is_changing_map = true, and unfreeze/unset in player.process.
	# That seems to work. God forgive me for writing such a hack.
	#
	# In hindsight, freeze only freezes the mouse/keyboard-movement components,
	# so the offending code is probably in there somewhere. Despite the fact that
	# I debugged through it. Several. Times. Repeatedly.
	#
	# It's probably the same bug that teleports monsters to the bottom of the map when
	# they are moving upward and collide into a solid tile.
	##########
	player.freeze()
	Globals.unfreeze_player_in_process = true
	
	self.add_child(player)
	
	SceneFadeManager.fade_in(self.get_tree(), Globals.SCENE_TRANSITION_TIME_SECONDS)
	
	if Globals.emit_battle_over_after_fade:
		Globals.emit_battle_over_after_fade = false
		Globals.emit_signal("battle_over")
	
	AudioManager.new().add_click_noise_to_controls($UI)

func schedule_autosave():
	if _should_autosave:
		yield(get_tree().create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), "timeout")
		self._auto_save()
	
func _auto_save():
	$UI.capture_screenshot()
	SaveManager.save_with_screenshot("autosave")
	var auto_save = $UI/AutoSave
	auto_save.modulate.a = 0
	var af = AlphaFluctuator.new(auto_save, 0.5)
	add_child(af)
	af.run(3)
	
func _is_walkable_and_no_transitions(tile_coords, transitions):
	if tile_coords.x < 0 or tile_coords.y < 0 or \
		tile_coords.x >= map.tiles_wide or tile_coords.y >= map.tiles_high:
			return false
	
	for transition in transitions:
		if tile_coords == transition:
			return false
	
	return true

func _exit_tree():
	if self.play_audio:
		self._audio_bgs.clean_up_audio()

func get_monsters():
	var to_return = {}
	for type in self._monsters.keys():
		to_return[type] = []
		for monster in self._monsters[type]:
			monster.data_object.x = monster.position.x
			monster.data_object.y = monster.position.y
			to_return[type].append(monster.data_object)
				
	return to_return

func freeze_monsters():
	for type in self._monsters.keys():
		for monster in self._monsters[type]:
			monster.freeze()
			
func unfreeze_monsters():
	for type in self._monsters.keys():
		for monster in self._monsters[type]:
			monster.unfreeze()

func hide_ui():
	for child in $UI/Control.get_children():
		if child is Button:
			child.visible = false

func show_ui():
	for child in $UI/Control.get_children():
		if child is Button:
			child.visible = true
			
func _populate_tiles(tilemap_data, tilemap, tile_ids, entity_tiles):
	for y in range(0, tilemap_data.height):
		for x in range(0, tilemap_data.width):
			var tile_name = tilemap_data.get_at(x, y)
			
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
		
		# In cases like the Cave, we have special tiles that indicate the exit.
		# If the tileset has such tiles, apply them (after autotiling).
		if destination.direction != null: # null = exit to overworld
			var direction = destination.direction
			var coordinates = destination.my_position
			var exit_type = "Exit" + direction.capitalize()
			
			if tile_ids.has(exit_type):
				tilemap.set_cell(coordinates.x, coordinates.y, tile_ids[exit_type])
		
		var warp_x = destination.my_position.x
		var warp_y = destination.my_position.y
		_create_warp_at(destination, warp_x, warp_y)
		
		# Create a row of warps. That way, you block the exit, no matter what.
		if map.map_type != "Overworld":
			if destination.direction == "up" or destination.direction == "down":
				_create_warp_at(destination, warp_x - 1, warp_y)
				_create_warp_at(destination, warp_x + 1, warp_y)
			elif destination.direction == "left" or destination.direction == "right":
				_create_warp_at(destination, warp_x, warp_y - 1)
				_create_warp_at(destination, warp_x, warp_y + 1)
		
func _create_warp_at(data, x, y):
	var warp = MapWarp.instance()
	warp.initialize_from(data)
	warp.position.x = x * Globals.TILE_WIDTH
	warp.position.y = y * Globals.TILE_HEIGHT
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
				_should_autosave = false # if quit/reload, will miss cutscene
				hide_ui()
				Globals.current_monster.is_alive = false
				if Globals.current_monster.replace_with_npc != null:
					var npc_class = Globals.quest.NPCS[Globals.current_monster.replace_with_npc]
					var replacement = npc_class.instance()
					replacement.position.x = Globals.current_monster.x
					replacement.position.y = Globals.current_monster.y
					self.add_child(replacement)
					replacement.name = Globals.current_monster.replace_with_npc
				if Globals.current_monster.attach_quest_npcs != null:
					self._spawn_attached_npcs(Globals.current_monster)
			
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
	
	######### bosses. Spawn only when expected (fought one boss? Only boss #2 spawns)
	
	# Don't apply this when maps have no variation (home/endgame)
	var dungeon_number = -1
	
	if map.variation != null:
		var dungeon_type = map.map_type + "/" + map.variation
		dungeon_number = Globals.world_areas.find(dungeon_type) # base 0
	if map.variation == null or dungeon_number == Globals.bosses_defeated:
		for boss_type in map.bosses.keys():
			var bosses = []
			for boss in map.bosses[boss_type]:
				if boss.is_alive:
					var instance = Boss.instance()
					instance.initialize_from(boss)
					self.add_child(instance)
					bosses.append(instance)
					
					if boss.attach_quest_npcs != null:
						self._spawn_attached_npcs(boss)
							
			self._bosses[boss_type] = bosses
	
	# Persist on save
	map.monsters = self._monsters
	
func _spawn_attached_npcs(boss):
	var all_npcs = []
	for npc in boss.attach_quest_npcs:
		var scene_constructor = Quest.NPCS[npc]
		var npc_instance = scene_constructor.instance()
		npc_instance.name = npc
		self.add_child(npc_instance)
		
		# https://trello.com/c/6Ok0apkN/59-you-can-talk-to-dad-when-hes-kidnapped-what
		# Baba can't talk in-dungeon to say cutscene stuff
		if npc == "Baba":
			npc_instance.can_talk = false
		
		var npc_position = _find_spot_near_boss(boss, all_npcs)
		all_npcs.append(npc_position)
		npc_instance.position = Vector2(npc_position.x * Globals.TILE_WIDTH, npc_position.y * Globals.TILE_HEIGHT)

# Returns coordinates near the boss.
func _find_spot_near_boss(boss, blocked_coordinates):
	var ground_tilemap = self.map.tile_data[0]
	
	# Find a nearby empty spot. Start under and to the left of the boss,
	# and iterate sideways, then upwards.
	var boss_tile_x = boss.x / Globals.TILE_WIDTH
	var boss_tile_y = boss.y / Globals.TILE_HEIGHT
	
	var x = boss_tile_x - 1
	var y = boss_tile_y - 1
	
	for tile_x in range(_NPC_MAX_DISTANCE_TO_BOSS):
		for tile_y in range(_NPC_MAX_DISTANCE_TO_BOSS):
			var tx = x + tile_x
			var ty = y - tile_y
			# On the map, not on the boss (2x2 tiles), and not already blocked by another NPC
			
			# https://www.pivotaltracker.com/story/show/164683595
			# Check around this tile so NPC doesn't spawn on a tile
			# next to, say, a lava tile that gets auto-tiled into lava.
			if tx >= 0 and tx < self.map.tiles_wide and ty >= 0 and ty < self.map.tiles_high and \
				not Vector2(tx, ty) in blocked_coordinates and \
				ground_tilemap.get_at(tx, ty) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx, ty - 1) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx + 1, ty - 1) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx + 1, ty) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx + 1, ty + 1) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx, ty + 1) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx - 1, ty + 1) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx - 1, ty) in Globals.WALKABLE_TILES and \
				ground_tilemap.get_at(tx - 1, ty - 1) in Globals.WALKABLE_TILES and \
				not self._is_boss_tile(tx, ty, boss_tile_x, boss_tile_y):
					return Vector2(tx, ty)
			
	# https://www.pivotaltracker.com/story/show/164847969
	# https://twitter.com/nightblade99/status/1109522513778733056
	# We couldn't find a spot. Idelaly, we should generate the map without this problem.
	# Realistically, we can't do that; pick any empty spot adjacent to the boss.
	for tx in range(boss_tile_x - 1, boss_tile_x + 2):
		for ty in range(boss_tile_y - 1, boss_tile_y + 2):
			
			if tx >= 0 and tx < self.map.tiles_wide and ty >= 0 and ty < self.map.tiles_high and \
				ground_tilemap.get_at(tx, ty) in Globals.WALKABLE_TILES and \
				not Vector2(tx, ty) in blocked_coordinates and \
				not self._is_boss_tile(tx, ty, boss_tile_x, boss_tile_y):
				return Vector2(tx, ty)
	
	# Worst case of the worst case: return a square on the 2x2 boss. Bottom-right one.
	return Vector2(boss_tile_x + 1, boss_tile_y + 1)

func _is_boss_tile(tile_x, tile_y, boss_tile_x, boss_tile_y):
	return tile_x >= boss_tile_x and tile_x <= boss_tile_x + 1 and \
		tile_y >= boss_tile_y and tile_y <= boss_tile_y + 1

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

func _process(elapsed):
	# eg. sin(4x) cycles four times per 2pi instead of once
	var CYCLE_FAST_MULTIPLIER = 2
	
	self._total_time += elapsed
	var stats_button = $UI/Control/StatsButton
	
	if Globals.player_data.unassigned_stats_points > 0:
		# Guaranteed to be at least 0.5. Goes over 1.0, so it stays solid longer
		# (it's like fade-to-solid and hold, then fade out and fade back in).
		var alpha = 0.5 + abs(sin(CYCLE_FAST_MULTIPLIER * self._total_time))
		stats_button.modulate = Color(1, 0.5, 0, alpha)
		stats_button.text = "! Stats"
	else:
		stats_button.modulate = Color(1, 1, 1, 1)
		stats_button.text = "Stats"
		

func _on_UI_opened_save_manager():
	freeze_monsters()

func _on_UI_closed_save_manager():
	unfreeze_monsters()