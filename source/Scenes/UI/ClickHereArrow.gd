extends Node2D

const _WAVE_HEIGHT = 32
const _SPEED_MULTIPLIER = 4

var tile_coordinates = Vector2(-1, -1)
var _total_seconds = 0


func _process(delta):
	_total_seconds += delta
	# Maps 1 ... -1 to 0 ... 2
	$Arrow.position.y = (cos(_total_seconds * _SPEED_MULTIPLIER) - 1) * _WAVE_HEIGHT