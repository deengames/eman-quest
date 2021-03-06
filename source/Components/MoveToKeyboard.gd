extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal cancel_destination
signal reached_destination
signal facing_new_direction

const Footsteps = preload("res://assets/audio/sfx/footstep.ogg")

export var speed = 0 # set by owning component
const ZERO_VECTOR = Vector2(0, 0)

var previously_facing = ""
var previously_pressed_key = false
var _audio_player

func _ready():
	_audio_player = AudioStreamPlayer.new()
	_audio_player.stream = Footsteps
	add_child(_audio_player)
	
func _physics_process(delta):
	if self.get_parent().can_move:
		self._move_to_keyboard()

func stop_footsteps_audio():
	_audio_player.stop()

func _move_to_keyboard():
	var velocity = Vector2(0, 0)
	var new_facing = self.previously_facing
	var pressed_key = false
	
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		velocity.x = 1
		new_facing = "Right"
		pressed_key = true
	elif Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		velocity.x = -1
		new_facing = "Left"
		pressed_key = true	
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		velocity.y = -1
		new_facing = "Up"
		pressed_key = true
	elif Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		velocity.y = 1
		new_facing = "Down"
		pressed_key = true

	if new_facing != self.previously_facing:
		emit_signal("facing_new_direction", new_facing)
		previously_facing = new_facing
	
	if velocity.x != 0 or velocity.y != 0:
		if not _audio_player.playing:
			_audio_player.play()
		velocity = velocity.normalized() * self.speed
		velocity = self.get_parent().move_and_slide(velocity, ZERO_VECTOR)
		self.emit_signal("cancel_destination") # if clicked, cancel that destination
	else:
		_audio_player.stop()
		if not pressed_key and previously_pressed_key:
			self.previously_facing = null
			# Not moving and not click-move: stop animation
			self.emit_signal("reached_destination")
	
	self.previously_pressed_key = pressed_key