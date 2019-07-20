extends "res://test/BaseIntegrationTest.gd"

const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const GenerateWorldScene = preload("res://Scenes/GenerateWorldScene.tscn")
const PopulatedMapScene = preload("res://Scenes/PopulatedMapScene.tscn")

func test_bosses_appear_when_matching_Globals_bosses_defeated():
	# If we're on boss #1, it should appear.
	
	### Arrange
	# Generate world
	var gen_scene = GenerateWorldScene.instance()
	gen_scene.delay_to_display = false
	add_child(gen_scene)
	
	Globals.bosses_defeated = 1
	var second_map_name_and_variation = Globals.world_areas[1]
	
	var second_map_name_and_variation_areas = Globals.maps[second_map_name_and_variation]
	# Find the boss map
	var second_boss_map = second_map_name_and_variation_areas[0]
	for map in second_map_name_and_variation_areas:
		if map.area_type == AreaType.AREA_TYPE.BOSS:
			second_boss_map = map
			break
	
	### Act
	var second_map = PopulatedMapScene.instance()
	second_map.play_audio = false
	second_map.initialize(second_boss_map)
	add_child(second_map)
	
	### Assert
	assert_eq(1, len(second_map._bosses.keys()))

func test_bosses_dont_appear_when_not_matching_Globals_bosses_defeated():
	# If we're on boss #1, boss #2 shouldn't appear.
	
	### Arrange
	# Generate world
	var gen_scene = GenerateWorldScene.instance()
	gen_scene.delay_to_display = false
	add_child(gen_scene)
	
	Globals.bosses_defeated = 1
	var third_map_name_and_variation = Globals.world_areas[2]
	
	var third_map_name_and_variation_areas = Globals.maps[third_map_name_and_variation]
	# Find the boss map
	var third_boss_map = third_map_name_and_variation_areas[0]
	for map in third_map_name_and_variation_areas:
		if map.area_type == AreaType.AREA_TYPE.BOSS:
			third_boss_map = map
			break
	
	### Act
	var third_map = PopulatedMapScene.instance()
	third_map.play_audio = false
	third_map.initialize(third_boss_map)
	add_child(third_map)
	
	### Assert
	assert_eq(0, len(third_map._bosses.keys()))