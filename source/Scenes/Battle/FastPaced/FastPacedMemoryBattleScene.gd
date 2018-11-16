extends Node2D

const BattleResolution = preload("res://Scripts/Battle/BattleResolution.gd")

const _MULTIPLIER_BASE = 1.1 # For attacks, 1.1^7 = ~2x, double if perfect pick...
const _MONSTER_NUM_TILES = 4

var _action_resolver = preload("res://Scripts/Battle/ActionResolver.gd").new()
var _player # BattlePlayer.new
var _monster_data = {}
var _multiplier = 0
var _actions_left = 0

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
	$RecallGrid.connect("correct_selected", self, "_on_correct_selected")
	
	self._update_health_displays()
	$StatusLabel.text = ""
	$NextTurnButton.visible = false
	self._start_next_turn()

# health and energy
func _update_health_displays():
	var player_health = self._player.current_health
	$PlayerControls/PlayerHealth.value = player_health
	$PlayerControls/PlayerHealth/Label.text = str(player_health)
	
	var monster_health = self._monster_data["health"]
	$MonsterControls/MonsterHealth.value = monster_health
	$MonsterControls/MonsterHealth/Label.text = str(monster_health)
	
	$ActionsLabel.text = "Actions: " + str(_actions_left)

func _on_picked_all_tiles():
	var num_right = $RecallGrid.selected_right
	self._multiplier = pow(_MULTIPLIER_BASE, num_right)
	$RecallGrid.make_unselectable()
	
	if self._is_players_turn:
		$ActionsPanel.visible = true
	else:
		self._resolve_monster_turn()

func _show_battle_end(is_victory):
	var popup = BattleResolution.end_battle(is_victory, self._monster_data)
	self.add_child(popup)
	popup.popup_centered()

func _resolve_players_turn(action):
	var message = self._action_resolver.resolve(action, self._player, self._monster_data, self._multiplier)
	$StatusLabel.text = message
	self._actions_left -= 1
	self._update_health_displays()
	
	if self._monster_data["health"] <= 0:
		self._show_battle_end(true)
	
	if self._actions_left == 0:
		$ActionsPanel.visible = false
		$NextTurnButton.visible = true

func _resolve_monster_turn():
	var message = self._action_resolver.monster_attacks(self._monster_data, self._player, self._multiplier, null)
	$StatusLabel.text = message
	
	self._update_health_displays()
	$NextTurnButton.visible = true

	if self._player.current_health <= 0:
		self._show_battle_end(false)

func _on_NextTurnButton_pressed():
	self._start_next_turn()

func _start_next_turn():
	# Set up next turn
	var num_tiles = 0
	
	self._is_players_turn = not self._is_players_turn
	$RecallGrid.reset()
	
	if self._is_players_turn:
		$TurnLabel.text = "Player attacks!"
		num_tiles = self._player.num_actions
	else:
		$TurnLabel.text = self._monster_data["type"] + " attacks!"
		num_tiles = _MONSTER_NUM_TILES
	
	$NextTurnButton.visible = false
	$ActionsPanel.visible = false

	# Players turn? Monsters turn and streamlined triggers = on?
	if (self._is_players_turn or
		(not self._is_players_turn and Features.is_enabled("streamlined battles: enemy triggers"))
	):
		# Execute
		var tiles = $RecallGrid.pick_tiles(num_tiles)
		$RecallGrid.show_tiles(tiles)
	# Monsters turn and streamlined triggers = off
	elif not self._is_players_turn and not Features.is_enabled("streamlined battles: enemy triggers"):
		self._resolve_monster_turn()
		# Avoid having to click Next Turn for nothing
		self._start_next_turn()

func _on_correct_selected():
	self._actions_left += 1
	# Updates actions-left
	self._update_health_displays()

func _on_AttackButton_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		self._resolve_players_turn("attack")

func _on_CriticalButton_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		self._resolve_players_turn("critical")

func _on_PotionButton_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		self._resolve_players_turn("heal")
