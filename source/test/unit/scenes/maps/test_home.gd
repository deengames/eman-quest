extends "res://test/BaseIntegrationTest.gd"

const Home = preload("res://Scenes/Maps/Home.tscn")
const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")

func test_ready_moves_player_to_entrance():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())
	var map = Home.instance()
	
	# Act
	add_child(map)
	
	# Assert
	var expected_location = map.get_node("Locations/Entrance").position
	assert_eq(Globals.player.position, expected_location)
	
func test_ready_moves_player_to_prebattle_position_if_set():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())	
	var map = Home.instance()
	# Doesn't make sense. Prod code sets it to an array.
	var pre_battle_position = Vector2(100, 200)
	Globals.pre_battle_position = pre_battle_position
	
	# Act
	add_child(map)
	
	# Assert
	assert_eq(Globals.player.position, pre_battle_position)
