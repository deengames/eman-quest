extends Node2D

const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")
const ForestGenerator = preload("res://Scripts/Generators/ForestGenerator.gd")

func _ready():
	self.generate_world()
	get_tree().change_scene("res://StartGame.tscn")

func generate_world():
	
	# return a dictionary, eg. "forest" => forest map
	Globals.maps = {
		"Overworld": OverworldGenerator.new().generate(),
		"Forest": ForestGenerator.new().generate()
	}