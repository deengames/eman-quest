extends Node

var equipment_name
var primary_stat
var primary_stat_modifier
var secondary_stat
var secondary_stat_modifier

func _init(equipment_name, primary_stat, primary_modifier, secondary_stat, secondary_modifier):
	self.equipment_name = equipment_name
	self.primary_stat = primary_stat
	self.primary_stat_modifier = primary_modifier
	self.secondary_stat = secondary_stat
	self.secondary_stat_modifier = secondary_modifier