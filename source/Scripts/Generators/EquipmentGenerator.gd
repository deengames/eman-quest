extends Node

const Equipment = preload("res://Entities/Equipment.gd")
const StatType = preload("res://Scripts/Enums/StatType.gd")

# type = weapon or armour
# primary_stat is a Stats. 
static func generate(type, primary_stat):
	var secondary_stat = randi() % StatType.StatType.size()
	
	while secondary_stat == primary_stat:
		secondary_stat = randi() % StatType.StatType.size()
	
	var primary_name = StatType.to_string(primary_stat)
	var secondary_name = StatType.to_string(secondary_stat)
	
	# Not exactly what we want, but works well with small powers like 10
	var item_name = _generate_name(primary_name, secondary_name)
		
	return Equipment.new(type, item_name, primary_stat, secondary_stat)

static func _generate_name(primary_stat, secondary_stat):
	var vowels = ["a", "i", "o", "u", "oo"]
	var name = ""
	var sounds = ["s", "sh", "ch", "b", "d", "n", "r", "z", "t", "m"]
	while len(name) < 6:
		name += sounds[randi() % len(sounds)]
		name += vowels[randi() % len(vowels)]
		
	return name.to_lower().capitalize()
	
	
	
	