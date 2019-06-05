extends Node

const MINIMUM_REQUIRED_DISTANCE = 10 # tiles

# Transitions is an array of MapDestination instances
static func is_distant_from_transitions(transitions, coordinates):
	var x = coordinates[0]
	var y = coordinates[1]
	
	var min_distance = 999999999
	for map_destination in transitions:
		# position is Vector2
		var position = map_destination.my_position
		var distance = sqrt(pow(position.x - x, 2) + pow(position.y - y, 2))
		min_distance = min(min_distance, distance)
	
	return min_distance >= MINIMUM_REQUIRED_DISTANCE