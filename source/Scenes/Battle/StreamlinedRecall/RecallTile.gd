extends Node2D

signal correct_selected
signal incorrect_selected
signal done_hiding

const _DISPLAY_SECONDS = 1

const _TILE_IMAGE_X = {
	"active": 0,
	"correct": 64,
	"incorrect": 128
}

const _COVER_IMAGE_COORDINATES = {
	"Forest/Slime": Vector2(0, 0),
	"Forest/Frost": Vector2(64, 0),
	"Forest/Death": Vector2(128, 0),
	
	"Cave/River": Vector2(192, 0),
	"Cave/Lava": Vector2(0, 64),
	
	"Dungeon/Castle": Vector2(64, 64),
	"Dungeon/Desert": Vector2(128, 64),
	
	"Final/Normal": Vector2(192, 64), # Mufsid
	"Home/Normal": Vector2(192, 64) # Hamza
}

var is_selectable = false
var _should_be_selected = false

func _ready():
	# Opaque by default
	$Cover.modulate = Color(1, 1, 1, 1)

func show_then_hide():
	yield(get_tree().create_timer(_DISPLAY_SECONDS), 'timeout')
	$Cover.visible = false
	$Contents.region_rect.position.x = _TILE_IMAGE_X["active"]
	#var random_offset = randf() * 0.25
	# Add random_offset to _DISPLAY_SECONDS to get random/cool fade
	yield(get_tree().create_timer(_DISPLAY_SECONDS), 'timeout')
	$Cover.visible = true
	self._should_be_selected = true
	self.emit_signal("done_hiding")

func reset():
	self._should_be_selected = false
	$Cover.visible = true
	$Cover.modulate = Color(1, 1, 1, 1)

# Full name is something like "Forest/Frost"
func set_cover_image(full_name):
	$Cover.region_rect.position = _COVER_IMAGE_COORDINATES[full_name]

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (self.is_selectable and event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		if self._should_be_selected:
			$Contents.region_rect.position.x = _TILE_IMAGE_X["correct"]
			self.emit_signal("correct_selected")
		else:
			$Contents.region_rect.position.x = _TILE_IMAGE_X["incorrect"]
			self.emit_signal("incorrect_selected")
		$Cover.visible = false
		self.is_selectable = false
		# Transparent when clicked
		$Cover.modulate = Color(1, 1, 1, 0.5)