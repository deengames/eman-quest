extends Node

const StatType = preload("res://Scripts/StatType.gd")

var type # weapon, armour, cloak, etc.
var equipment_name
var primary_stat
var primary_stat_modifier
var secondary_stat
var secondary_stat_modifier
var grid_tiles
var tile_type

# Name, primary stat they boost and the amount
func _init(type, equipment_name, primary_stat, primary_modifier, 
	# Secondary stat they boost and the amount
	secondary_stat, secondary_modifier,
	# Grid effect: number of guaranteed tiles generated, and their type
	grid_tiles, tile_type):
		
	self.type = type
	self.equipment_name = equipment_name
	self.primary_stat = primary_stat
	self.primary_stat_modifier = primary_modifier
	self.secondary_stat = secondary_stat
	self.secondary_stat_modifier = secondary_modifier
	self.grid_tiles = grid_tiles
	self.tile_type = tile_type

func str():
	return (self.equipment_name + "\n" +
		"+" + str(self.primary_stat_modifier) + " " + StatType.to_string(self.primary_stat) + "\n" +
		"+" + str(self.secondary_stat_modifier) + " " + StatType.to_string(self.secondary_stat) + "\n" +
		"Adds " + str(self.grid_tiles) + " " + self.tile_type + " tiles")