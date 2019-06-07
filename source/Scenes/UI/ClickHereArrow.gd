extends Node2D

const _WAVE_HEIGHT = 16
const _SPEED_MULTIPLIER = 4
const _MAGIC_OFFSET = -24

var tile_coordinates = Vector2(-1, -1)
var _total_seconds = 0


func _process(delta):
	_total_seconds += delta
	# Use -cos because the arrow position in the editor is the *bottom* of the wave
	# For the same reason, add -1 map from -1..1 to -2..0
	# Then divide by 2 to map from -2..0 to -1..0
	# IDK why this doesn't work, hence _MAGIC_OFFSET
	var offset = ((cos(_total_seconds * _SPEED_MULTIPLIER) - 1) / 2)
	$Arrow.position.y = _MAGIC_OFFSET + (offset * _WAVE_HEIGHT)