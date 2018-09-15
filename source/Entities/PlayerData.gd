extends Node

### 
# PLAYER DATA! That persistent thing that represents our player across scenes.
# Anything persisted here is saved in save-games.
###

var level = 1
var experience_points = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func gain_xp(xp):
	var old_xp = self.experience_points
	self.experience_points += xp
	# TODO: Detect and note level up

func get_next_level_xp():
	# Doubles every level. 50, 100, 200, 400, ...
	return pow(2, (level - 2)) * 100