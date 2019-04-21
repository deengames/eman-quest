extends "res://test/BaseIntegrationTest.gd"

const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func test_ready_moves_player_to_entrance():
	Globals.maps["Overworld"] = OverworldGenerator.new().generate(Globals.maps.keys())
	Globals.pre_battle_position = Vector2(999, 999)
	
	# Act
	SceneManagement.change_map_to(get_tree(), "Overworld")
	
	# Assert
	assert_null(Globals.pre_battle_position)

func do_nothing(tree, populated_map):
	pass