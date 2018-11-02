extends Node

const DictionaryHelper = preload("res://Scripts/DictionaryHelper.gd")
const Equipment = preload("res://Entities/Equipment.gd")
const EquipmentGenerator = preload("res://Scripts/Generators/EquipmentGenerator.gd")
const StatType = preload("res://Scripts/Enums/StatType.gd")

### 
# PLAYER DATA! That persistent thing that represents our player across scenes.
# Anything persisted here is saved in save-games.
###

const STATS_POINTS_TO_RAISE_ENERGY = 5
const STATS_POINTS_TO_RAISE_PICKED_TILES = 10
const STATS_POINTS_TO_RAISE_ACTIONS = 20
# TODO: cost doubles but points don't double, and stats gained
# don't double. Consider increasing this per level or something.
const _STATS_POINTS_PER_LEVEL = 5

var level = 1
var experience_points = 0

var health = 60
var strength = 8
var defense = 5

var max_energy = 20
var num_pickable_tiles = 5
var num_actions = 3

var unassigned_stats_points = 0

var assigned_points = {
	"health": 0,
	"strength": 0,
	"defense": 0,
	"energy": 0, # requires ~5 points to raise it by 1
	"num_pickable_tiles": 0, # requires ~10 points to raise it by 1
	"num_actions": 0 # requires ~20 points to raise it by 1
}

var weapon
var armour
var equipment = []
var key_items = []

func _init():
	randomize()
	self.weapon = EquipmentGenerator.generate("weapon", StatType.Strength, 10)
	self.armour = EquipmentGenerator.generate("armour", StatType.Defense, 8)

func to_dict():
	return {
		"filename": "res://Entities/PlayerData.gd",
		"level": self.level,
		"experience_points": self.experience_points,
		"health": self.health,
		"strength": self.strength,
		"defense": self.defense,
		"max_energy": self.max_energy,
		"num_pickable_tiles": self.num_pickable_tiles,
		"num_actions": self.num_actions,
		"unassigned_stats_points": self.unassigned_stats_points,
		"assigned_points": self.assigned_points,
		"weapon": self.weapon.to_dict(),
		"armour": self.armour.to_dict(),
		"equipment": DictionaryHelper.array_to_dictionary(self.equipment),
		"key_items": DictionaryHelper.array_to_dictionary(self.key_items)
	}

static func from_dict(dict):
	var to_return = new()
	to_return.level = dict["level"]
	to_return.experience_points = dict["experience_points"]
	to_return.health = dict["health"]
	to_return.strength = dict["strength"]
	to_return.defense = dict["defense"]
	to_return.max_energy = dict["max_energy"]
	to_return.num_pickable_tiles = dict["num_pickable_tiles"]
	to_return.num_actions = dict["num_actions"]
	to_return.unassigned_stats_points = dict["unassigned_stats_points"]
	to_return.assigned_points = dict["assigned_points"]
	to_return.weapon = Equipment.from_dict(dict["weapon"])
	to_return.armour = Equipment.from_dict(dict["armour"])
	to_return.equipment = DictionaryHelper.array_from_dictionary(dict["equipment"])
	to_return.key_items = DictionaryHelper.array_from_dictionary(dict["key_items"])
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

# This whole section is super hacky.
func added_energy_point():
	if self.assigned_points["energy"] % STATS_POINTS_TO_RAISE_ENERGY == 0:
		self.max_energy += 1

func removed_energy_point():
	# If we gain a point at 5, 10, ... we lose a point at 4, 9, ...
	if self.assigned_points["energy"] % STATS_POINTS_TO_RAISE_ENERGY == STATS_POINTS_TO_RAISE_ENERGY - 1:
		self.max_energy -= 1
	
func added_pickable_tiles_point():
	if self.assigned_points["num_pickable_tiles"] % STATS_POINTS_TO_RAISE_PICKED_TILES == 0:
		self.num_pickable_tiles += 1
	
func removed_pickable_tiles_point():
	if self.assigned_points["num_pickable_tiles"] % STATS_POINTS_TO_RAISE_PICKED_TILES == STATS_POINTS_TO_RAISE_PICKED_TILES - 1:
		self.num_pickable_tiles -= 1
	
func added_actions_point():
	if self.assigned_points["num_actions"] % STATS_POINTS_TO_RAISE_ACTIONS == 0:
		self.num_actions += 1

func removed_actions_point():
	if self.assigned_points["num_actions"] % STATS_POINTS_TO_RAISE_ACTIONS == STATS_POINTS_TO_RAISE_ACTIONS - 1:
		self.num_actions -= 1