extends KinematicBody2D

export var speed = 200
signal reached_destination

var _target_posiiton = null # Vector2
var _velocity = Vector2(0, 0)

func run(direction, tiles):
	var dx = 0
	var dy = 0
	
	if direction == "Down" or direction == "Up":
		dy = tiles * Globals.TILE_HEIGHT
		if direction == "Up":
			dy *= -1
	elif direction == "Left" or direction == "Right":
		dx = tiles * Globals.TILE_HEIGHT
		if direction == "Left":
			dx *= -1
	
	self._target_posiiton = Vector2(self.position.x + dx, self.position.y + dy)
	self._velocity = Vector2(dx, dy).normalized() * self.speed
	
	$AnimationPlayer.play("Walk " + direction)

func _physics_process(delta):
	if self._target_posiiton != null:
		self.move_and_slide(self._velocity)
		
		if (self._target_posiiton - self.position).length() <= Globals.TILE_WIDTH / 2:
			self._target_posiiton = null
			self.emit_signal("reached_destination")
			