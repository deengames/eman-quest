extends Node2D

func show_map_name(area_map):
	var full_name
	
	if area_map.variation != null:
		full_name = area_map.variation + " " + area_map.map_type
	else:
		full_name = area_map.map_type
		
	$MapNamePanel/Label.text = full_name