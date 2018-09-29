extends KinematicBody2D

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

const MOVE_SPEED = 100
const CHANGE_DESTINATION_EVERY_N_SECONDS = 1
const IS_BOSS = false

const data = {
	"type": "Slime",
	"health": 30,
	"strength": 10,
	"defense": 2,
	"turns": 1,
	"experience points": 10,
	
	"skill_probability": 40, # 40 = 40%
	"skills": {
		# These should add up to 100
		"chomp": 100 # 20%,
	}
}

# pixel coordinates
var x = 0
var y = 0
var data_object = null # Monster.new() instance

var _destination = Vector2(0, 0)
var _destination_last_changed = OS.get_ticks_msec()

func _ready():
	self._pick_destination()

func initialize(x, y):
	self.x = x
	self.y = y
	
func initialize_from(monster):
	self.data_object = monster
	self.position.x = monster.x
	self.position.y = monster.y

func _process(delta):
	var now = OS.get_ticks_msec()
	
	if now - self._destination_last_changed > CHANGE_DESTINATION_EVERY_N_SECONDS * 1000:
		self._pick_destination()
		_destination_last_changed = now

func _pick_destination():
	var root = get_tree().get_root()
	var current_map = Globals.current_map
	self._destination.x = Globals.randint(0, (current_map.tiles_wide - 1) * Globals.TILE_WIDTH)
	self._destination.y = Globals.randint(0, (current_map.tiles_high - 1) * Globals.TILE_HEIGHT)

	self._face_current_direction()

func _physics_process(delta):
	if self._destination != null:
		var velocity = (self._destination - self.position).normalized() * self.MOVE_SPEED
		move_and_slide(velocity) 

func _on_Area2D_body_entered(body):
	SceneManagement.switch_to_battle_if_touched_player(self, body)

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