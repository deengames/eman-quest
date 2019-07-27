extends Sprite

const _CHEST_OPEN_X = 64

const AudioManager = preload("res://Scripts/AudioManager.gd")
const Equipment = preload("res://Entities/Equipment.gd")
const StatusWindow = preload("res://Scenes/UI/StatusWindow.tscn")

var is_opened = false
var contents # equipment instance
var tile_x = 0
var tile_y = 0
# reference to the map instance; another TreasureChest, created by .new
var data = null

var _player_is_in_range = false

### DO NOT USE _INIT HERE! This will break when you create this with .instance()
# For details, see: https://github.com/godotengine/godot/issues/15866
func initialize(x, y, contents):
	self.tile_x = x
	self.tile_y = y
	self.contents = contents

func initialize_from(data):
	self.data = data
	self.contents = data.contents
	self.is_opened = data.is_opened
	self.position.x = data.tile_x * Globals.TILE_WIDTH
	self.position.y = data.tile_y * Globals.TILE_HEIGHT
	if data.is_opened:
		self._destroy()

func to_dict():
	return {
		"filename": "res://Entities/TreasureChest.gd",
		"is_opened": self.is_opened,
		"contents": self.contents.to_dict(),
		"tile_x": self.tile_x,
		"tile_y": self.tile_y
	}

static func from_dict(dict):
	var to_return = new()
	var contents = Equipment.from_dict(dict["contents"])
	to_return.initialize(dict["tile_x"], dict["tile_y"], contents)
	to_return.is_opened = dict["is_opened"]
	return to_return

func open():
	if not self.is_opened:
		# Grant item
		Globals.player_data.equipment.append(self.contents)
		self.contents.roll_modifiers()
		self._consume()
		AudioManager.new().play_sound("open-treasure-chest")
		
		Globals.player.stop_footsteps_audio()
		
		var window = StatusWindow.instance()
		window.set_text("Found a(n) " + self.contents.equipment_name)
		get_tree().current_scene.get_node("UI").add_child(window)
		window.popup_centered()
		
		window.connect("popup_hide", self, "_destroy")

func _consume():
	self.is_opened = true
	if self.data != null:
		self.data.is_opened = true
	self._appear_open()

func _destroy():
	queue_free()

func _appear_open():
	self.region_rect.position.x = _CHEST_OPEN_X

func _on_Area2D_body_entered(body):
	if not self.is_opened and body == Globals.player:
		self._player_is_in_range = true

func _on_Area2D_body_exited(body):
	if not self.is_opened and body == Globals.player:
		self._player_is_in_range = false

func _process(delta):
	if not self.is_opened and self._player_is_in_range and Input.is_key_pressed(KEY_SPACE):
		self.open()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (not self.is_opened and self._player_is_in_range and 
	(event is InputEventMouseButton and event.pressed) or
	(OS.has_feature("Android") and event is InputEventMouseMotion)):
		self.open()