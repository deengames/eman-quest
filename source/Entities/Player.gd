extends KinematicBody2D

var _cant_fight_from = null
var CANT_FIGHT_FOR_SECONDS = 5
var facing = "down"

var can_move = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	Globals.player = self
	
	if Features.is_enabled("zoom-out maps"):
		$Camera2D.zoom = Vector2(4, 4)
		
	# Strange bug that I can't quite figure out. Broke on New Game.
	if Globals.current_map == null:
		return
	
	# Set camera bounds. Hand-crafted maps don't have these variables.
	if Globals.current_map.map_type != "Final" and Globals.current_map.map_type != "Home":
		$Camera2D.limit_right = Globals.current_map.tiles_wide * Globals.TILE_WIDTH
		$Camera2D.limit_bottom = Globals.current_map.tiles_high * Globals.TILE_HEIGHT
	else:
		$Camera2D.limit_right = Globals.current_map.get_tiles_wide() * Globals.TILE_WIDTH
		$Camera2D.limit_bottom = Globals.current_map.get_tiles_high() * Globals.TILE_HEIGHT
		
func temporarily_no_battles():
	self._cant_fight_from = OS.get_ticks_msec()

func _process(delta):
	# https://www.pivotaltracker.com/story/show/163181477
	if Globals.unfreeze_player_in_process and not self.can_move:
		self.unfreeze()
		Globals.unfreeze_player_in_process = false
		
	var now = OS.get_ticks_msec()
	if self._cant_fight_from != null and (now - self._cant_fight_from) / 1000 >= CANT_FIGHT_FOR_SECONDS:
		self._cant_fight_from = null

func can_fight():
	return self._cant_fight_from == null

func _change_animation():
	if self.can_move:
		$AnimationPlayer.play("Walk " + self.facing)

func _on_facing_new_direction(new_direction):
	self.facing = new_direction
	self._change_animation()

func _on_reached_destination():
	$AnimationPlayer.stop()

func _on_cancel_destination():
	$MoveToClick.cancel_destination()

func freeze():
	self.can_move = false
	$AnimationPlayer.stop()

func unfreeze():
	self.can_move = true