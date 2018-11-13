extends Sprite

const _TILE_IMAGE_X = {
	"inactive": 0,
	"active": 48
}

func show_then_hide():
	self.region_rect.position.x = _TILE_IMAGE_X["active"]
	var random_offset = randf() * 0.25
	yield(get_tree().create_timer(1 + random_offset), 'timeout')
	self.region_rect.position.x = _TILE_IMAGE_X["inactive"]