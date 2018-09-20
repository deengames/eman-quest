extends StaticBody2D

const _CHEST_OPEN_X = 64

var is_opened = false
var contents # equipment instance
var tile_x = 0
var tile_y = 0

func _init(x, y, contents):
	self.tile_x = x
	self.tile_y = y

func open():
	if not self.is_opened:
		# Grant item
		Globals.player_data.inventory.append(self.contents)
		self.consume()

func consume():
	self.is_opened = true
	self._appear_open()

func _appear_open():
	$Sprite.region_rect.position.x = _CHEST_OPEN_X