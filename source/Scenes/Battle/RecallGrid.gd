extends Node2D

const RecallTile = preload("res://Scenes/Battle/RecallTile.tscn")

const _WIDTH_IN_TILES = 7 # please extend width, not height
const _HEIGHT_IN_TILES = 7
const _TILE_WIDTH = 64
const _TILE_HEIGHT = 64
const _ACTIVE_TILES = 7

var num_tiles = 0
var ready_tiles = 0
var _tile_controls = []

func _ready():
	for y in range(_HEIGHT_IN_TILES):
		for x in range(_WIDTH_IN_TILES):
			var tile = RecallTile.instance()
			tile.position = Vector2(x * _TILE_WIDTH, y * _TILE_HEIGHT)
			tile.name = "Tile" + str(x) + "-" + str(y)
			self.add_child(tile)
			self._tile_controls.append(tile)

func pick_tiles(difficulty):
	var tiles_left = 7
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

func _tile_done_hiding():
	ready_tiles += 1
	if ready_tiles == self.num_tiles:
		for tile in self._tile_controls:
			tile.is_selectable = true
	