extends Node2D

const Player = preload("res://Entities/Player.tscn")

### 
# A static map. Contains instructions to work + common code.
###

signal clicked_on_map(position)

const map_type = "" # used in transitions, plays nice with code that looks up map_type.

func _ready():
	Globals.current_map = self
	Globals.player = Player.instance()
	self.add_child(Globals.player)

func get_tiles_wide():
	return $Ground.get_used_rect().size.x

func get_tiles_high():
	return $Ground.get_used_rect().size.y

# Duplicated in PopulatedMapScene.gd
# https://docs.godotengine.org/en/3.0/tutorials/inputs/inputevent.html#how-does-it-work
# Fires if nothing else handled the event, it seems.
func _unhandled_input(event):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		var position = get_global_mouse_position()
		# Clicks seem ... off for some reason. Not sure why. Adjust manually.
		position.x -= Globals.TILE_WIDTH / 2
		position.y -= Globals.TILE_HEIGHT
		Globals.emit_signal("clicked_on_map", position)