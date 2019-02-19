extends Node

const DictionaryHelper = preload("res://Scripts/DictionaryHelper.gd")
const Equipment = preload("res://Entities/Equipment.gd")
const StatType = preload("res://Scripts/Enums/StatType.gd")

### 
# PLAYER DATA! That persistent thing that represents our player across scenes.
# Anything persisted here is saved in save-games.
###

const STATS_POINTS_TO_RAISE_ACTIONS = 20
# TODO: cost doubles but points don't double, and stats gained
# don't double. Consider increasing this per level or something.
const _STATS_POINTS_PER_LEVEL = 5
const _MAX_TECH_POINTS = 20

var level = 1
var experience_points = 0

var health = 60
var strength = 15
var defense = 5

var num_actions = 5

var unassigned_stats_points = 0

var assigned_points = {
	"health": int(0),
	"strength": int(0),
	"defense": int(0),
	"num_actions": int(0) # requires ~20 points to raise it by 1
}

var weapon = Equipment.new("weapon", "Dagger", StatType.Strength, StatType.Defense)
var armour = Equipment.new("armour", "Tunic", StatType.Defense, StatType.Health)
var equipment = []
var key_items = []

var tech_points = 0

func _init():
	weapon.primary_stat_modifier = 7
	weapon.secondary_stat_modifier = 2
	armour.primary_stat_modifier = 5
	armour.secondary_stat_modifier = 7

func to_dict():
	return {
		"filename": "res://Entities/PlayerData.gd",
		"level": self.level,
		"experience_points": self.experience_points,
		"health": self.health,
		"strength": self.strength,
		"defense": self.defense,
		"num_actions": self.num_actions,
		"unassigned_stats_points": self.unassigned_stats_points,
		"assigned_points": self.assigned_points,
		"weapon": self.weapon.to_dict(),
		"armour": self.armour.to_dict(),
		"equipment": DictionaryHelper.array_to_dictionary(self.equipment),
		"key_items": DictionaryHelper.array_to_dictionary(self.key_items),
		"tech_points": self.tech_points
	}

static func from_dict(dict):
	var to_return = new()
	to_return.level = dict["level"]
	to_return.experience_points = dict["experience_points"]
	to_return.health = dict["health"]
	to_return.strength = dict["strength"]
	to_return.defense = dict["defense"]
	to_return.num_actions = dict["num_actions"]
	to_return.unassigned_stats_points = dict["unassigned_stats_points"]
	to_return.assigned_points = dict["assigned_points"]
	to_return.weapon = Equipment.from_dict(dict["weapon"])
	to_return.armour = Equipment.from_dict(dict["armour"])
	to_return.equipment = DictionaryHelper.array_from_dictionary(dict["equipment"])
	to_return.key_items = DictionaryHelper.array_from_dictionary(dict["key_items"])
	to_return.tech_points = dict["tech_points"]
	return to_return
	
func gain_xp(xp):
	var old_xp = self.experience_points
	self.experience_points += xp
	while self.experience_points >= get_next_level_xp():
		self.level += 1
		self.unassigned_stats_points += _STATS_POINTS_PER_LEVEL

func get_next_level_xp():
	# Doubles every level. 50, 100, 200, 400, ...
	return pow(2, (level - 2)) * 100

# Very hacky. But tested.
func added_actions_point():
	if int(self.assigned_points["num_actions"]) % STATS_POINTS_TO_RAISE_ACTIONS == 0:
		self.num_actions += 1

func removed_actions_point():
	if int(self.assigned_points["num_actions"]) % STATS_POINTS_TO_RAISE_ACTIONS == STATS_POINTS_TO_RAISE_ACTIONS - 1:
		self.num_actions -= 1

func add_tech_point():
	self.tech_points += 1
	self.tech_points = int(min(self.tech_points, _MAX_TECH_POINTS))

func spend_tech_points(n):
	if self.tech_points >= n:
		self.tech_points -= n