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
			self.add_child(tile)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
