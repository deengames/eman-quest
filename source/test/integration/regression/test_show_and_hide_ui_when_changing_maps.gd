extends "res://test/BaseIntegrationTest.gd"

const PopulatedMapScene = preload('res://scenes/PopulatedMapScene.tscn')

func test_hide_ui_hides_ui_on_populated_map_instance():
	var map = PopulatedMapScene.instance()
	# precondition
	var ui = map.get_node("UI")
	for child in ui.get_children():
		assert_true(child.visible)
	
	# Act
	map.hide_ui()
	
	# Assert
	for child in ui.get_children():
		assert_false(child.visible)

func test_show_ui_shows_ui_on_populated_map_instance():
	var map = PopulatedMapScene.instance()
	# precondition
	var ui = map.get_node("UI")
	for child in ui.get_children():
		child.visible = false
	
	# Act
	map.show_ui()
	
	# Assert
	for child in ui.get_children():
		assert_true(child.visible)

