extends Node

const BattleResultsWindow = preload("res://Scenes/Battle/BattleResultsWindow.tscn")

# Takes is_victory (true/false) and monster data
# Returns the popup to call add_child on
static func end_battle(is_victory, monster_data):
	Globals.won_battle = is_victory
	var battle_results = BattleResultsWindow.instance()
	battle_results.initialize(monster_data)
	return battle_results