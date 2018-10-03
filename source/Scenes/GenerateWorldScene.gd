extends Node2D

const AreaMap = preload("res://Entities/AreaMap.gd")
const ForestGenerator = preload("res://Scripts/Generators/ForestGenerator.gd")
const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	self.generate_world()
	SceneManagement.change_map_to(get_tree(), "Overworld")
	get_tree().current_scene.get_node("UI").show_intro_story()
	
func generate_world():
	
	# return a dictionary, eg. "forest" => forest map
	Globals.maps = {
		"Overworld": OverworldGenerator.new().generate(),
		"Forest": ForestGenerator.new().generate()
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
	