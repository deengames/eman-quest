extends Node

# Given an array of entities, return an array where every item is created by
# calling to_dict on the items in the input array.
static func array_to_dictionary(array):
	var to_return = []
	
	for item in array:
		to_return.append(item.to_dict())
	
	return to_return

static func array_from_dictionary(array):
	var to_return = []
	
	for item in array:
		var type = load(item["filename"])
		var value = type.from_dict(item)
		to_return.append(value)
	
	return to_return

# Given an dictionary of arrays, return a dictionary where every array item
# is created by calling to_dict on the items in the input dictionary.
static func dictionary_values_to_dictionary(dict):
	var to_return = {}
	
	for key in dict.keys():
		var a = []
		
		for item in dict[key]:
			a.append(item.to_dict())
			
		to_return[key] = a
	
	return to_return

static func dictionary_values_from_dictionary(dict):
	var to_return = {}
	
	for key in dict.keys():
		var a = []
		
		for item in dict[key]:
			var type = load(item["filename"])
			var value = type.from_dict(item)
			a.append(value)
			
		to_return[key] = a
	
	return to_return

# Converts a nullable Vector2 to a dictionary
static func vector2_to_dict(v):
	if v == null: return null
	
	return {
		"x": v.x,
		"y": v.y
	}

static func dict_to_vector2(dict):
	if dict == null or not dict.has("x") or not dict.has("y"):
		return null
		
	return Vector2(dict["x"], dict["y"])