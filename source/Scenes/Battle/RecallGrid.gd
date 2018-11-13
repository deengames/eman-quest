extends Node2D

const RecallTile = preload("res://Scenes/Battle/RecallTile.tscn")

const _WIDTH_IN_TILES = 7 # please extend width, not height
const _HEIGHT_IN_TILES = 7
const _TILE_WIDTH = 48
const _TILE_HEIGHT = 48
const _ACTIVE_TILES = 7

const _TILE_IMAGE_X = {
	"inactive": 0,
	"active": 48
}

func _ready():
	for y in range(_HEIGHT_IN_TILES):
		for x in range(_WIDTH_IN_TILES):
			var tile = RecallTile.instance()
			tile.position = Vector2(x * _TILE_WIDTH, y * _TILE_HEIGHT)
			tile.name = "Tile" + str(x) + "-" + str(y)
			self.add_child(tile)

func pick_tiles(difficulty):
	var tiles_left = 7
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
		sprite.region_rect.position.x = _TILE_IMAGE_X["active"]