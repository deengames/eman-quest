extends KinematicBody2D

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

const _MOVE_SPEED = 100
const _CHANGE_DESTINATION_EVERY_N_SECONDS = [1, 2]
const IS_BOSS = false

var data = {}
var _change_after_seconds = 0

# pixel coordinates
var x = 0
var y = 0
var data_object = null # Monster.new() instance

var _frozen = false
var _destination = Vector2(0, 0)
var _destination_last_changed = OS.get_ticks_msec()

func _ready():
	# Random float the range specified
	var min_time = _CHANGE_DESTINATION_EVERY_N_SECONDS[0]
	var max_time = _CHANGE_DESTINATION_EVERY_N_SECONDS[1]
	var time_range = max_time - min_time
	self._change_after_seconds = (randf() * time_range) + min_time
	
	self._pick_destination()

func initialize(x, y):
	self.x = x
	self.y = y
	
func initialize_from(monster):
	self.data_object = monster
	self.position.x = monster.x
	self.position.y = monster.y
	var type = monster.data["type"].replace(' ', '')
	$Sprite.texture = load("res://assets/images/monsters/" + type + ".png")

func freeze():
	self._frozen = true
	$AnimationPlayer.stop()

func unfreeze():
	self._frozen = false
	self._pick_destination()

func to_dict():
	var data = null
	if self.data_object != null:
		data = self.data_object.data
		
	var to_return = {
		"filename": "res://Entities/Battle/Monster.gd",
		"x": self.position.x,
		"y": self.position.y,
		"data": data
	}
	return to_return

static func from_dict(dict):
	if dict == null:
		return null
		
	var to_return = new()
	var data = dict["data"]
	to_return.initialize(dict["x"], dict["y"])
	# needed for loading and re-instantiating on map
	#to_return.data_object = data
	to_return.data = data
	return to_return


func _process(delta):
	if not self._frozen:
		var now = OS.get_ticks_msec()
		
		if now - self._destination_last_changed > self._change_after_seconds * 1000:
			self._pick_destination()
			_destination_last_changed = now

func _pick_destination():
	var root = get_tree().get_root()
	var current_map = Globals.current_map
	# null when you first load/enter a map
	if Features.is_enabled("monsters chase you") and Globals.player != null:
		self._destination = Globals.player.position
	else:
		self._destination.x = Globals.randint(0, (current_map.tiles_wide - 1) * Globals.TILE_WIDTH)
		self._destination.y = Globals.randint(0, (current_map.tiles_high - 1) * Globals.TILE_HEIGHT)

	self._face_current_direction()

func _physics_process(delta):
	if not self._frozen:
		if self._destination != null:
			var velocity = (self._destination - self.position).normalized() * self._MOVE_SPEED
			move_and_slide(velocity) 

func _on_Area2D_body_entered(body):
	if not self._frozen:
		SceneManagement.switch_to_battle_if_touched_player(get_tree(), self, body)

func _face_current_direction():
	var delta = (self._destination - self.position).normalized()
	if abs(delta.x) >= abs(delta.y):
		if delta.x <= 0:
			self._face("Left")
		else:
			self._face("Right")
	else:
		if delta.y <= 0:
			self._face("Up")
		else:
			self._face("Down")

func _face(direction):
	$AnimationPlayer.play("Walk " + direction) 