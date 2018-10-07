extends Node2D

const AreaMap = preload("res://Entities/AreaMap.gd")
const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const ForestGenerator = preload("res://Scripts/Generators/ForestGenerator.gd")
const MapLayoutGenerator = preload("res://Scripts/Generators/MapLayoutGenerator.gd")
const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	self.generate_world()
	SceneManagement.change_map_to(get_tree(), "Overworld")
	get_tree().current_scene.get_node("UI").show_intro_story()
	
func generate_world():
	
	var forest_generator = ForestGenerator.new()
	var forest_layout = MapLayoutGenerator.generate_layout(4)
	var forest_maps = []
	
	for submap in forest_layout:
		var map = forest_generator.generate(submap.room_type)
		forest_maps.append(map)
	
	# return a dictionary, eg. "forest" => forest map
	Globals.maps = {
		"Overworld": OverworldGenerator.new().generate(),
		# TODO: delegate to the MapLayoutGenerator or another generator
		"Forest": forest_maps
	}
	
	Globals.story_data = {
		"village_name": self._generate_village_name(),
		"boss_type": self._generate_boss_type()
	}

func _generate_village_name():
	var options = ['Nahr', 'Bahr', 'Shajar', 'Aqram', 'Hira']
	return options[randi() % len(options)]

func _generate_boss_type():
	var options = ['snake', 'black dog', 'gargoyle']
	return options[randi() % len(options)]
	