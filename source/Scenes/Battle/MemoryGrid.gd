extends Node2D

const GridTile = preload("res://Scenes/Battle/GridTile.tscn")
const _ENERGY_TILES_PERCENT = 0.2 # 0.2 = 20%
var tiles_wide = 0
var tiles_high = 0
var _all_tiles = []
var _max_pickable_tiles = 0
var _shocked_turns_left = 0
var _tiles_to_freeze # null if shock (50% of tiles on RHS), else number to randomly freeze
var _tiles_picked = []

signal all_tiles_picked
signal tile_picked
signal instant_action

func initialize(tiles_wide, tiles_high, _advanced_mode = false, num_pickable_tiles = 5):
	self.tiles_wide = tiles_wide
	self.tiles_high = tiles_high
	self._max_pickable_tiles = num_pickable_tiles

	# Construct grid dynamically. We could alternatively show them in the
	# editor as 8x8, but hide them if we don't want them.
	self._create_tiles(_advanced_mode)
	self.reset()

func _ready():
	# Just shown for UI editing/preview
	$ColorRect.visible = false

func reset():
	self._tiles_picked = []
	for tile in self._all_tiles:
		tile.reset()
	
	# Generate some "guaranteed" tiles, like energy.
	# Don't do this over other "guaranteed" tiles, like equipment-generated tiles.
	self._generate_guaranteed_tiles()
	
	if self._shocked_turns_left > 0:
		var tiles_to_freeze = self._tiles_to_freeze
		if tiles_to_freeze == null:
			# Freeze RHS, it's a shock attack
			for tile in self._all_tiles:
				if tile.tile_x >= floor(self.tiles_wide / 2):
					tile.hide_contents()
					tile.freeze()
		else:
			for tile in self._all_tiles:
				if tiles_to_freeze > 0 and randi() % 100 <= 30:
						tile.hide_contents()
						tile.freeze()
						tiles_to_freeze -= 1
				
		self._shocked_turns_left -= 1

func shock(turns):
	self._shocked_turns_left += turns

func freeze(turns, tiles_to_freeze):
	self._shocked_turns_left += turns
	self._tiles_to_freeze = tiles_to_freeze

func _create_tiles(advanced_mode):
	for y in range(0, self.tiles_high):
		for x in range(0, self.tiles_wide):
			var tile = GridTile.instance()
			tile.tile_x = x
			tile.tile_y = y
			
			if advanced_mode:
				tile.show_advanced_actions = true
				
			tile.connect("tile_selected", self, "_on_tile_selected")
			self.add_child(tile)
			tile.position.x = tile.width * x
			tile.position.y = tile.height * y
			self._all_tiles.append(tile)

func _generate_guaranteed_tiles():
	self._generate_energy_tiles()
	self._generate_weapon_tiles()
	self._generate_armour_tiles()

func _change_random_convertable_tile_to(contents):
	var tx = randi() % self.tiles_wide
	var ty = randi() % self.tiles_high
	var tile = self._all_tiles[(ty * self.tiles_wide) + tx]
	if tile.do_not_change == false:
		tile.contents = contents
		tile.refresh_display()
		tile.do_not_change = true

func _generate_energy_tiles():
	if Features.is_enabled("actions require energy"):
		var num_tiles = ceil(_ENERGY_TILES_PERCENT * self.tiles_wide * self.tiles_high)
		while num_tiles > 0:
			self._change_random_convertable_tile_to("energy")
			num_tiles -= 1

func _generate_weapon_tiles():
	if Features.is_enabled("equipment generates tiles"):
		var num_tiles = Globals.player_data.weapon.grid_tiles
		var tile_type = Globals.player_data.weapon.tile_type
		while num_tiles > 0:
			self._change_random_convertable_tile_to(tile_type)
			num_tiles -= 1

func _generate_armour_tiles():
	if Features.is_enabled("equipment generates tiles"):
		var num_tiles = Globals.player_data.armour.grid_tiles
		var tile_type = Globals.player_data.armour.tile_type
		while num_tiles > 0:
			self._change_random_convertable_tile_to(tile_type)
			num_tiles -= 1

func _on_tile_selected(tile):
	# Emit even if wrong, that ends turn on instant mode
	if Features.is_enabled("instant actions"):
		self.emit_signal("instant_action", tile.contents)
			
	if tile.contents != "wrong":
		self._tiles_picked.append(tile.contents)
			
		# If unlimited picks is off, we check if you picked "enough" choices. If on,
		# ignore this (turn ends when you pick a wrong choice).
		if not Features.is_enabled("unlimited battle choices") and len(self._tiles_picked) == _max_pickable_tiles:
			self._picked_all_tiles()
	else:
		self._picked_all_tiles()
		
	self.emit_signal("tile_picked", tile.contents)

func _picked_all_tiles():
	for tile in self._all_tiles:
		tile.freeze()
		
	self.emit_signal("all_tiles_picked", self._tiles_picked)