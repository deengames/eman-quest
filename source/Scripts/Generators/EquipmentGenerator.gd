extends Node

const StatType = preload("res://Scripts/StatType.gd")

# primary_stat is a Stats. Power is a number that indicates relative power.
# Something that's power 20 should be roughly 2x as strong as something power 10.
static func generate(primary_stat, power):
	var secondary_stat = randi() % StatType.StatType.size()
	
	while secondary_stat == primary_stat:
		secondary_stat = randi() % StatType.StatType.size()
	
	var keys = StatType.StatType.keys()	
	print("P=" + keys[primary_stat] + " and s=" + keys[secondary_stat])