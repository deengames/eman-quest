extends Node

static func array_to_dictionary(array):
	var to_return = []
	
	for item in array:
		to_return.append(item.to_dict())
	
	return to_return

static func dictionary_values_to_dictionary(dict):
	var to_return = {}
	
	for key in dict.keys():
		var a = []
		
		for item in dict[key]:
			a.append(item.to_dict())
			
		to_return[key] = a
	
	return to_return