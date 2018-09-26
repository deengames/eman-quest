extends Node2D

const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")
const ForestGenerator = preload("res://Scripts/Generators/ForestGenerator.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const StoryWindow = preload("res://Scenes/UI/StoryWindow.tscn")

func _ready():
	
	self.generate_world()
	
	$Status.visible = false
	
	var story_window = StoryWindow.instance()
	story_window.show_intro_story()
	get_tree().get_root().add_child(story_window)
	story_window.popup_centered()

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
	