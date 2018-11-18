extends Node2D

const RecallTile = preload("res://Scenes/Battle/StreamlinedRecall/RecallTile.tscn")

signal picked_all_tiles
signal correct_selected

const _WIDTH_IN_TILES = 7 # please extend width, not height
const _HEIGHT_IN_TILES = 7
const _TILE_WIDTH = 64
const _TILE_HEIGHT = 64
const _ACTIVE_TILES = 7

var battle_player
var num_tiles = 0

var ready_tiles = 0
var selected_right = 0
var selected_wrong = 0

var _tile_controls = []

func _ready():
	for y in range(_HEIGHT_IN_TILES):
		for x in range(_WIDTH_IN_TILES):
			
			var tile = RecallTile.instance()
			tile.position = Vector2(x * _TILE_WIDTH, y * _TILE_HEIGHT)
			tile.name = "Tile" + str(x) + "-" + str(y)
			tile.connect("correct_selected", self, "_on_correct_tile_selected")
			tile.connect("incorrect_selected", self, "_on_incorrect_tile_selected")
			
			self.add_child(tile)
			self._tile_controls.append(tile)
	
	self.reset()

func pick_tiles(num_tiles):
	var tiles_left = num_tiles
	self.num_tiles = tiles_left
	var tiles = []
	
	while tiles_left > 0:
		var next_tile = Vector2(randi() % _WIDTH_IN_TILES, randi() % _HEIGHT_IN_TILES)
		if not next_tile in tiles:
			tiles.append(next_tile)
			tiles_left -= 1
	
	return tiles

func show_tiles(tiles):
	for tile in tiles:
		var sprite = self.get_node("Tile" + str(tile.x) + "-" + str(tile.y))
		sprite.show_then_hide()
		sprite.connect("done_hiding", self, "_tile_done_hiding")

func reset():
	self.ready_tiles = 0
	self.selected_wrong = 0
	self.selected_right = 0
	for tile in self._tile_controls:
		tile.reset()

func make_unselectable():
	for tile in self._tile_controls:
		tile.is_selectable = false

func _tile_done_hiding():
	ready_tiles += 1
	if ready_tiles == self.num_tiles: # As many tiles as expected, report done hiding
		for tile in self._tile_controls:
			tile.is_selectable = true

func _on_correct_tile_selected():
	self.selected_right += 1
	self.emit_signal("correct_selected")
	self._emit_if_done()
	
func _on_incorrect_tile_selected():
	self.selected_wrong += 1
	self._emit_if_done()

func _emit_if_done():
	if self.selected_wrong + self.selected_right == self.num_tiles:
		self.emit_signal("picked_all_tiles")