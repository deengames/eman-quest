extends Node2D

signal correct_selected
signal incorrect_selected
signal done_hiding

const _DISPLAY_SECONDS = 1

const _TILE_IMAGE_X = {
	"inactive": 0,
	"active": 64,
	"correct": 128,
	"incorrect": 192
}
var is_selectable = false
var _should_be_selected = false

func show_then_hide():
	yield(get_tree().create_timer(_DISPLAY_SECONDS), 'timeout')
	$Contents.region_rect.position.x = _TILE_IMAGE_X["active"]
	var random_offset = randf() * 0.25
	yield(get_tree().create_timer(_DISPLAY_SECONDS + random_offset), 'timeout')
	$Contents.region_rect.position.x = _TILE_IMAGE_X["inactive"]
	self._should_be_selected = true
	self.emit_signal("done_hiding")

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (self.is_selectable and event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		if self._should_be_selected:
			$Contents.region_rect.position.x = _TILE_IMAGE_X["correct"]
			self.emit_signal("correct_selected")
		else:
			$Contents.region_rect.position.x = _TILE_IMAGE_X["incorrect"]
			self.emit_signal("incorrect_selected")
		self.is_selectable = false
