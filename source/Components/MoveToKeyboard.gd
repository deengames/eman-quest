extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal cancel_destination
signal reached_destination
signal facing_new_direction

export var speed = 0 # set by owning component

var previously_facing = ""
var previously_pressed_key = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	self._move_to_keyboard()

func _move_to_keyboard():	
	var velocity = Vector2(0, 0)
	var new_facing = self.previously_facing
	var pressed_key = false
	
	if Input.is_key_pressed(KEY_RIGHT):
		velocity.x = 1
		new_facing = "Right"
		pressed_key = true
	elif Input.is_key_pressed(KEY_LEFT):
		velocity.x = -1
		new_facing = "Left"
		pressed_key = true	
	if Input.is_key_pressed(KEY_UP):
		velocity.y = -1
		new_facing = "Up"
		pressed_key = true
	elif Input.is_key_pressed(KEY_DOWN):
		velocity.y = 1
		new_facing = "Down"
		pressed_key = true

	if new_facing != self.previously_facing:
		emit_signal("facing_new_direction", new_facing)
		previously_facing = new_facing
	
	if velocity.x != 0 or velocity.y != 0:
		velocity = velocity.normalized() * self.speed
		self.get_parent().move_and_slide(velocity)
		self.emit_signal("cancel_destination") # if clicked, cancel that destination
	elif not pressed_key and previously_pressed_key:
		self.previously_facing = null
		# Not moving and not click-move: stop animation
		self.emit_signal("reached_destination")
	
	self.previously_pressed_key = pressed_key