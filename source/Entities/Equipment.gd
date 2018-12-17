extends Node

const StatType = preload("res://Scripts/Enums/StatType.gd")

# Generate items that always are in this range of our stats, eg. weapons that
# are in the range of 50-75% of our current strength.
const _MIN_STAT_MULTIPLIER = 0.5
const _MAX_STAT_MULITPLIER = 0.75

var type # weapon, armour, cloak, etc.
var equipment_name
var primary_stat
var primary_stat_modifier = 0
var secondary_stat
var secondary_stat_modifier = 0

# Name, primary stats they boost
func _init(type, equipment_name, primary_stat, secondary_stat):
		
	self.type = type
	self.equipment_name = equipment_name
	self.primary_stat = primary_stat
	self.secondary_stat = secondary_stat

func roll_modifiers():
	self.primary_stat_modifier = _get_random_amount(self.primary_stat)
	self.secondary_stat_modifier = _get_random_amount(self.secondary_stat)

func to_dict():
	return ({
		"filename": "res://Entities/Equipment.gd",
		"type": self.type,
		"equipment_name": self.equipment_name,
		"primary_stat": self.primary_stat,
		"primary_stat_modifier": self.primary_stat_modifier,
		"secondary_stat": self.secondary_stat,
		"secondary_stat_modifier": self.secondary_stat_modifier
	})

static func _get_random_amount(stat_name):
	var amount = 0
	
	if stat_name == StatType.Health:
		amount = Globals.player_data.health
	elif stat_name == StatType.Strength:
		amount = Globals.player_data.strength
	elif stat_name == StatType.Defense:
		amount = Globals.player_data.defense
	
	var min_amount = ceil(amount * _MIN_STAT_MULTIPLIER)
	var max_amount = ceil(amount * _MAX_STAT_MULITPLIER)
	
	return randint(min_amount, max_amount)

# Returns integer value from min to max inclusive
# Source: https://godotengine.org/qa/2539/how-would-i-go-about-picking-a-random-number
static func randint(minimum, maximum):
	return range(minimum, maximum + 1)[randi() % range(minimum, maximum + 1).size()]

static func from_dict(dictionary):
	var equipment = new(dictionary["type"], dictionary["equipment_name"],
		dictionary["primary_stat"],
		dictionary["secondary_stat"])
	
	equipment.primary_stat_modifier = dictionary["primary_stat_modifier"]
	equipment.secondary_stat_modifier = dictionary["secondary_stat_modifier"]
	
	return equipment

func str():
	return (self.equipment_name + "\n" +
		"+" + str(self.primary_stat_modifier) + " " + StatType.to_string(self.primary_stat) + "\n" +
		"+" + str(self.secondary_stat_modifier) + " " + StatType.to_string(self.secondary_stat) + "\n")