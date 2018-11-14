extends Node2D

const _MULTIPLIER_BASE = 1.1 # For attacks, 1.1^7 = ~2x, double if perfect pick...
const _MONSTER_NUM_TILES = 4

var _action_resolver = preload("res://Scripts/Battle/ActionResolver.gd").new()
var _player # BattlePlayer.new
var _monster_data = {}

var _is_players_turn = false

func set_combatants(player, monster_data):
	self._player = player
	self._monster_data = monster_data
	self._monster_data["max_health"] = self._monster_data["health"]
	$RecallGrid.battle_player = player

func _ready():
	var image_name = self._monster_data["type"].replace(' ', '')
	$MonsterControls/MonsterHealth.max_value = self._monster_data["max_health"]
	$MonsterControls/MonsterSprite.texture = load("res://assets/images/monsters/" + image_name + ".png")
	$PlayerControls/PlayerHealth.max_value = self._player.max_health
	
	$RecallGrid.connect("picked_all_tiles", self, "_on_picked_all_tiles")
	
	self._update_health_displays()
	self._show_next_turn()

func _show_next_turn():
	self._is_players_turn = not self._is_players_turn
	var num_tiles = 0
	
	if self._is_players_turn:
		$TurnLabel.text = "Player attacks!"
		num_tiles = self._player.num_actions
	else:
		$TurnLabel.text = self._monster_data["type"] + " attacks!"
		num_tiles = _MONSTER_NUM_TILES
		
	$StatusLabel.text = ""
	
	var tiles = $RecallGrid.pick_tiles(num_tiles)
	$RecallGrid.reset()
	$RecallGrid.show_tiles(tiles)
	$NextTurnButton.visible = false

# health and energy
func _update_health_displays():
	var player_health = self._player.current_health
	$PlayerControls/PlayerHealth.value = player_health
	$PlayerControls/PlayerHealth/Label.text = str(player_health)
	
	var monster_health = self._monster_data["health"]
	$MonsterControls/MonsterHealth.value = monster_health
	$MonsterControls/MonsterHealth/Label.text = str(monster_health)

func _on_picked_all_tiles():
	var num_right = $RecallGrid.selected_right
	var multiplier = pow(_MULTIPLIER_BASE, num_right)
	$RecallGrid.make_unselectable()
	
	if self._is_players_turn:
		self._resolve_players_turn("attack", multiplier)
	else:
		self._resolve_monster_turn(multiplier)
		
	$NextTurnButton.visible = true

func _resolve_players_turn(action, multiplier):
	var message = self._action_resolver.resolve(action, self._player, self._monster_data, multiplier)
	$StatusLabel.text = message

func _resolve_monster_turn(multiplier):
	var message = self._action_resolver.monster_attacks(self._monster_data, self._player, multiplier, null)
	$StatusLabel.text = message

func _on_NextTurnButton_pressed():
	self._show_next_turn()
