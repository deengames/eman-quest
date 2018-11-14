extends Node2D

var _player # BattlePlayer.new
var _monster_data = {}

# TODO: as difficulty increases, increase number of tiles to find, and how
# spread out they are from each other.
var difficulty = 1
var _is_players_turn = false

func set_combatants(player, monster_data):
	self._player = player
	self._monster_data = monster_data
	self._monster_data["max_health"] = self._monster_data["health"]

func _ready():
	var image_name = self._monster_data["type"].replace(' ', '')
	$MonsterControls/MonsterHealth.max_value = self._monster_data["max_health"]
	$MonsterControls/MonsterSprite.texture = load("res://assets/images/monsters/" + image_name + ".png")
	$PlayerControls/PlayerHealth.max_value = self._player.max_health
	
	self._update_health_displays()
	$StatusLabel.text = ""

	self._show_next_turn()

func _show_next_turn():
	self._is_players_turn = not self._is_players_turn
	var num_tiles = 7 # typically, memory is 7 +- 2 items
	var tiles = $RecallGrid.pick_tiles(difficulty)
	$RecallGrid.show_tiles(tiles)

# health and energy
func _update_health_displays():
	var player_health = self._player.current_health
	$PlayerControls/PlayerHealth.value = player_health
	$PlayerControls/PlayerHealth/Label.text = str(player_health)
	
	var monster_health = self._monster_data["health"]
	$MonsterControls/MonsterHealth.value = monster_health
	$MonsterControls/MonsterHealth/Label.text = str(monster_health)