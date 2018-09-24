extends KinematicBody2D

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

const MOVE_SPEED = 100
const CHANGE_DESTINATION_EVERY_N_SECONDS = 1

# TODO: class? Or, dictionary of name => data?
const data = {
	"type": "Slime",
	"health": 30,
	"strength": 10,
	"defense": 4,
	"turns": 1,
	"experience points": 10,
	
	"skill_probability": 40, # 40 = 40%
	"skills": {
		# These should add up to 100
		"chomp": 100 # 20%,
	}
}

var _destination = Vector2(0, 0)
var _destination_last_changed = OS.get_ticks_msec()

func _ready():
	self._pick_destination()
	var root = get_tree().get_root()

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

func _physics_process(delta):
	if self._destination != null:
		var velocity = (self._destination - self.position).normalized() * self.MOVE_SPEED
		move_and_slide(velocity) 

func _on_Area2D_body_entered(body):
	SceneManagement.switch_to_battle_if_touched_player(self, body)