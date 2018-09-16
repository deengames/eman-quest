extends Node

### 
# PLAYER DATA! That persistent thing that represents our player across scenes.
# Anything persisted here is saved in save-games.
###

const STATS_POINTS_TO_RAISE_ENERGY = 5
const STATS_POINTS_TO_RAISE_PICKED_TILES = 10
const STATS_POINTS_TO_RAISE_ACTIONS = 20
const _STATS_POINTS_PER_LEVEL = 5

var level = 1
var experience_points = 0

var health = 60
var strength = 7
var defense = 5

var max_energy = 20
var num_pickable_tiles = 5
var num_actions = 3

var unassigned_stats_points = 10

var assigned_points = {
	"health": 0,
	"strength": 0,
	"defense": 0,
	"energy": 0, # requires ~5 points to raise it by 1
	"num_pickable_tiles": 0, # requires ~10 points to raise it by 1
	"num_actions": 0 # requires ~20 points to raise it by 1
}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func gain_xp(xp):
	var old_xp = self.experience_points
	self.experience_points += xp
	while self.experience_points >= get_next_level_xp():
		self.level += 1
		self.unassigned_stats_points += _STATS_POINTS_PER_LEVEL

func get_next_level_xp():
	# Doubles every level. 50, 100, 200, 400, ...
	return pow(2, (level - 2)) * 100