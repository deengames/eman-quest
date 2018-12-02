extends KinematicBody2D

var _cant_fight_from = null
var CANT_FIGHT_FOR_SECONDS = 5
var facing = "down"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	Globals.player = self
	
	if Features.is_enabled("zoom-out maps"):
		$Camera2D.zoom = Vector2(4, 4)
		
	# Set camera bounds
	$Camera2D.limit_right = Globals.current_map.tiles_wide * Globals.TILE_WIDTH
	$Camera2D.limit_bottom = Globals.current_map.tiles_high * Globals.TILE_HEIGHT

func temporarily_no_battles():
	self._cant_fight_from = OS.get_ticks_msec()

func _process(delta):
	var now = OS.get_ticks_msec()
	if self._cant_fight_from != null and (now - self._cant_fight_from) / 1000 >= CANT_FIGHT_FOR_SECONDS:
		self._cant_fight_from = null

func can_fight():
	return self._cant_fight_from == null

func _change_animation():
	$AnimationPlayer.play("Walk " + self.facing)

func _on_facing_new_direction(new_direction):
	self.facing = new_direction
	self._change_animation()

func _on_reached_destination():
	$AnimationPlayer.stop()

func _on_cancel_destination():
	$MoveToClick.cancel_destination()
