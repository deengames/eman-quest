extends "res://test/BaseIntegrationTest.gd"

const EndGameMap = preload("res://Scenes/Maps/EndGameMap.tscn")
const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")

func test_ready_moves_player_to_entrance():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())
	var map = EndGameMap.instance()
	
	# Act
	add_child(map)
	
	# Assert
	var expected_location = map.get_node("Locations/Entrance").position
	assert_eq(Globals.player.position, expected_location)
	
func test_ready_moves_player_to_prebattle_position_if_set():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())
	var map = EndGameMap.instance()
	# Doesn't make sense. Prod code sets it to an array.
	var pre_battle_position = Vector2(100, 200)
	Globals.pre_battle_position = pre_battle_position
	
	# Act
	add_child(map)
	
	# Assert
	assert_eq(Globals.player.position, pre_battle_position)

func test_ready_removes_endgame_objects_if_defeated_less_than_3_bosses():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())
	var map = EndGameMap.instance()
	
	# Act
	add_child(map)
	
	# Assert
	assert_null(map.get_node("FinalEventsTrigger"))
	assert_null(map.get_node("Jinn"))
	assert_null(map.get_node("Umayyah"))
	
func test_ready_removes_jinn_if_seen_endgame_events():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())
	var map = EndGameMap.instance()
	Globals.showed_final_events = true
	
	# Act
	add_child(map)
	
	# Assert
	assert_null(map.get_node("Jinn"))