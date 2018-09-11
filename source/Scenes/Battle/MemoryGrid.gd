extends Node2D

const GridTile = preload("res://Scenes/Battle/GridTile.tscn")

var tiles_wide = 0
var tiles_high = 0
var _all_tiles = []
var _max_pickable_tiles = 0
var _shocked_turns_left = 0
var _tiles_picked = []

signal all_tiles_picked
signal tile_picked

func initialize(tiles_wide, tiles_high, _advanced_mode = false, num_pickable_tiles = 5):
	self.tiles_wide = tiles_wide
	self.tiles_high = tiles_high
	self._max_pickable_tiles = num_pickable_tiles

	# Construct grid dynamically. We could alternatively show them in the
	# editor as 8x8, but hide them if we don't want them.
	self._create_tiles(_advanced_mode)

func _ready():
	# Just shown for UI editing/preview
	$ColorRect.visible = false

func reset():
	self._tiles_picked = []
	for tile in self._all_tiles:
		tile.reset()
	
	if self._shocked_turns_left > 0:
		for tile in self._all_tiles:
			if tile.tile_x >= floor(self.tiles_wide / 2):
				tile.hide_contents()
				tile.freeze()
				
		self._shocked_turns_left -= 1

func shock(turns):
	self._shocked_turns_left += turns

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

func _on_tile_selected(tile):
	if tile.contents != "wrong":
		self._tiles_picked.append(tile.contents)
		if len(self._tiles_picked) == _max_pickable_tiles:
			self._picked_all_tiles()
	else:
		self._picked_all_tiles()
		
	self.emit_signal("tile_picked", tile.contents)

func _picked_all_tiles():
	for tile in self._all_tiles:
		tile.freeze()
		
	self.emit_signal("all_tiles_picked", self._tiles_picked)