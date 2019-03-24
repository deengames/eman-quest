extends "res://addons/gut/test.gd"

const GenerateWorldScene = preload("res://Scenes/GenerateWorldScene.tscn")

func test_generate_generates_maps():
	# Generate world
	var gen_scene = GenerateWorldScene.instance()
	gen_scene.delay_to_display = false
	add_child(gen_scene)
	
	assert_not_null(Globals.maps)
	assert_not_null(Globals.world_areas)