extends Node

const StatType = preload("res://Scripts/Enums/StatType.gd")

var type # weapon, armour, cloak, etc.
var equipment_name
var primary_stat
var primary_stat_modifier
var secondary_stat
var secondary_stat_modifier

# Name, primary stat they boost and the amount
func _init(type, equipment_name, primary_stat, primary_modifier, 
	# Secondary stat they boost and the amount
	secondary_stat, secondary_modifier):
		
	self.type = type
	self.equipment_name = equipment_name
	self.primary_stat = primary_stat
	self.primary_stat_modifier = primary_modifier
	self.secondary_stat = secondary_stat
	self.secondary_stat_modifier = secondary_modifier

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

static func from_dict(dictionary):
	var equipment = new(dictionary["type"], dictionary["equipment_name"],
		dictionary["primary_stat"], dictionary["primary_stat_modifier"],
		dictionary["secondary_stat"], dictionary["secondary_stat_modifier"])
		
	return equipment

func str():
	return (self.equipment_name + "\n" +
		"+" + str(self.primary_stat_modifier) + " " + StatType.to_string(self.primary_stat) + "\n" +
		"+" + str(self.secondary_stat_modifier) + " " + StatType.to_string(self.secondary_stat) + "\n")