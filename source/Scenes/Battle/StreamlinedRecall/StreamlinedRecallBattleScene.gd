extends Node2D

const BattleResolution = preload("res://Scripts/Battle/BattleResolution.gd")
const MonsterScaler = preload("res://Scripts/Battle/MonsterScaler.gd")

const _MULTIPLIER_BASE = 1.1 # For attacks, 1.1^7 = ~2x, double if perfect pick...
const _MONSTER_NUM_TILES = 4
const _MONSTER_TURN_DISPLAY_SECONDS = 2

const _ACTION_POINTS_COST = {
	"attack": 2,
	"critical": 3,
	"heal": 1,
	"defend": 1
}

var _action_resolver = preload("res://Scripts/Battle/ActionResolver.gd").new()
var _player = preload("res://Entities//Battle/BattlePlayer.gd").new()
var _monster_data = {}
var _multiplier = 0
var _actions_left = 0

var _is_players_turn = false

func _ready():
	
	randomize()
	
	var map_type
	if typeof(Globals.current_map) == TYPE_STRING: # final map
		map_type = "Final"
	else:
		map_type = Globals.current_map.map_type
	
	# For things like the final map, assume "normal" if missing
	var variation = "Normal"
	if typeof(Globals.current_map) != TYPE_STRING and "variation" in Globals.current_map:
		variation = Globals.current_map.variation
		
	self._set_background_image(map_type, variation)
	self._set_recall_tile_image(map_type, variation)
	
	$ActionsPanel.self_modulate = Color(1, 1, 1, 0.5)
	
	var image_name = self._monster_data["type"].replace(' ', '')
	$MonsterControls/MonsterHealth.max_value = self._monster_data["max_health"]
	$MonsterControls/MonsterSprite.texture = load("res://assets/images/monsters/" + image_name + ".png")
	$PlayerControls/PlayerHealth.max_value = self._player.max_health
	
	$RecallGrid.battle_player = self._player
	$RecallGrid.connect("picked_all_tiles", self, "_on_picked_all_tiles")
	$RecallGrid.connect("correct_selected", self, "_on_correct_selected")
	
	if not Features.is_enabled("defend action"):
		$ActionsPanel/Controls/DefendButton.visible = false
	
	self._update_health_displays()
	$StatusLabel.text = ""
	$NextTurnButton.visible = false
	self._start_next_turn()
	
	_player.connect("poison_damaged", self, "_on_poison_damaged")

func set_monster_data(data):
	MonsterScaler.scale_monster_data(data)
	data["next_round_turns"] = data["turns"]
	data["max_health"] = data["health"]
	self._monster_data = data

func _set_background_image(map_type, variation):
	var background_filename = "res://assets/images/battle/battlebacks/" + variation + "-" + map_type + ".png"
	$Background.texture = load(background_filename)

# Different recal image per map type
func _set_recall_tile_image(map_type, variation):
	var full_name = map_type + "/" + variation
	$RecallGrid.set_tile_image(full_name)

# health and energy
func _update_health_displays():
	var player_health = self._player.current_health
	$PlayerControls/PlayerHealth.value = player_health
	$PlayerControls/PlayerHealth/Label.text = str(player_health)
	if _player.is_poisoned():
		$PlayerControls/PlayerHealth/Label.text += " (p)"
	
	var monster_health = self._monster_data["health"]
	$MonsterControls/MonsterHealth.value = monster_health
	$MonsterControls/MonsterHealth/Label.text = str(monster_health)
	
	$ActionsLabel.text = "Actions: " + str(_actions_left)

func _on_picked_all_tiles():
	var num_right = $RecallGrid.selected_right
	self._multiplier = pow(_MULTIPLIER_BASE, num_right)
	$RecallGrid.make_unselectable()
	self._disable_unusable_action_buttons()
	
	if self._is_players_turn:
		if num_right > 0:
			$ActionsPanel/Controls.visible = true
			
			if "critical" in self._player.disabled_actions:
				self._disable_action_button($ActionsPanel/Controls/CriticalButton)
			
			if "attack" in self._player.disabled_actions:
				self._disable_action_button($ActionsPanel/Controls/AttackButton)
			
			if "items" in self._player.disabled_actions:
				self._disable_action_button($ActionsPanel/Controls/PotionButton)
			
		else:
			$StatusLabel.text = "Missed a turn!"
			yield(get_tree().create_timer(_MONSTER_TURN_DISPLAY_SECONDS), 'timeout')
			self._start_next_turn()
	else:
		self._resolve_monster_turn()

func _show_battle_end(is_victory):
	var popup = BattleResolution.end_battle(is_victory, self._monster_data)
	self.add_child(popup)
	popup.popup_centered()

func _resolve_players_turn(action):
	self._actions_left -= _ACTION_POINTS_COST[action]
	
	var message = self._action_resolver.resolve(action, self._player, self._monster_data, self._multiplier)
	$StatusLabel.text = message
	self._update_health_displays()
	
	if self._monster_data["health"] <= 0:
		self._show_battle_end(true)
	
	if self._actions_left == 0: 
		$ActionsPanel/Controls.visible = false
		$NextTurnButton.visible = true

func _resolve_monster_turn():
	var message = self._action_resolver.monster_attacks(self._monster_data, self._player, 0, null)
	$StatusLabel.text = message
	self._update_health_displays() # show health decrease
	yield(get_tree().create_timer(_MONSTER_TURN_DISPLAY_SECONDS), 'timeout')
	
	 # times defended, apply poison damage, etc. Emits a signal that shows
	# a message about poison damage.
	self._player.reset()
	# We may have been poisoned, update again.
	self._update_health_displays()
	
	if self._player.current_health <= 0:
		self._show_battle_end(false)
	
	# Avoid having to click Next Turn for nothing
	self._start_next_turn()

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
		self._player.reset_disabled_actions()
	
	$NextTurnButton.visible = false
	$ActionsPanel/Controls.visible = false

	if self._player.is_asleep:
		$StatusLabel.text = "You snore!"
		self._player.is_asleep = false
		yield(get_tree().create_timer(_MONSTER_TURN_DISPLAY_SECONDS), 'timeout')
		self._start_next_turn()
	# Players turn? Monsters turn and streamlined triggers = on?
	elif (self._is_players_turn or
		(not self._is_players_turn and Features.is_enabled("streamlined battles: enemy triggers"))
	):
		# Execute
		var tiles = $RecallGrid.pick_tiles(num_tiles)
		$RecallGrid.show_tiles(tiles)
	# Monsters turn and streamlined triggers = off
	elif not self._is_players_turn and not Features.is_enabled("streamlined battles: enemy triggers"):
		self._resolve_monster_turn()

func _on_correct_selected():
	self._actions_left += 1
	# Updates actions-left
	self._update_health_displays()

func _on_AttackButton_pressed():
	self._resolve_players_turn("attack")
	self._disable_unusable_action_buttons()

func _on_PotionButton_pressed():
	self._resolve_players_turn("heal")
	self._disable_unusable_action_buttons()

func _on_CriticalButton_pressed():
	self._resolve_players_turn("critical")
	self._disable_unusable_action_buttons()

func _on_DefendButton_pressed():
	self._resolve_players_turn("defend")
	self._disable_unusable_action_buttons()

func _disable_unusable_action_buttons():
	self._enable_action_button($ActionsPanel/Controls/AttackButton)
	self._enable_action_button($ActionsPanel/Controls/CriticalButton)
	self._enable_action_button($ActionsPanel/Controls/PotionButton)
	self._enable_action_button($ActionsPanel/Controls/DefendButton)
	
	if self._actions_left < _ACTION_POINTS_COST["attack"]:
		self._disable_action_button($ActionsPanel/Controls/AttackButton)
	if self._actions_left < _ACTION_POINTS_COST["critical"]:
		self._disable_action_button($ActionsPanel/Controls/CriticalButton)
	if self._actions_left < _ACTION_POINTS_COST["heal"]:
		self._disable_action_button($ActionsPanel/Controls/PotionButton)
	if self._actions_left < _ACTION_POINTS_COST["defend"]:
		self._disable_action_button($ActionsPanel/Controls/DefendButton)
		
func _disable_action_button(button):
	button.disabled = true
	# Fade out 50% so hopefully the user can tell that it's disabled
	button.get_node("Sprite").modulate.a = 0.5

func _enable_action_button(button):
	button.disabled = false
	button.get_node("Sprite").modulate.a = 1
	
func _on_poison_damaged(damage):
	$StatusLabel.text = "Posioned for " + str(damage) + " damage!"
	yield(get_tree().create_timer(_MONSTER_TURN_DISPLAY_SECONDS), 'timeout')
