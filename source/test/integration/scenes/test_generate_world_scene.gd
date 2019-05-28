extends "res://test/BaseIntegrationTest.gd"

const GenerateWorldScene = preload("res://Scenes/GenerateWorldScene.tscn")

func test_generate_generates_maps_and_submaps():
	# Generate world
	var gen_scene = GenerateWorldScene.instance()
	gen_scene.delay_to_display = false
	add_child(gen_scene)
	
	assert_not_null(Globals.maps)
	assert_not_null(Globals.world_areas)

	assert_eq(len(Globals.world_areas), 3) # 3 generated, overworld, home, endgame
	assert_eq(len(Globals.maps), 3 + 3) # 3 generated, overworld, home, endgame
	
	var map_names = Globals.maps.keys()
	var expected_static_maps = ["Overworld", "Home", "Final"]
	
	for expected in expected_static_maps:
		assert_true(expected in map_names)
	
	var EXPECTED_SUBMAPS_PER_MAP = 4 + 2 # four original + 2 added/extra
	
	for map in map_names:
		if not map in expected_static_maps:
			var actual_submaps = Globals.maps[map]
			assert_eq(len(actual_submaps), EXPECTED_SUBMAPS_PER_MAP)
	
	