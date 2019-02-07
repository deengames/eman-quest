extends Node2D

const BattleResolution = preload("res://Scripts/Battle/BattleResolution.gd")
const MonsterScaler = preload("res://Scripts/Battle/MonsterScaler.gd")

const _MULTIPLIER_BASE = 1.25 # five attacks = 8x (1 + 1.25 + 1.25^2 + ... + 1.25^n)
const _MONSTER_NUM_TILES = 4
const _MONSTER_TURN_DISPLAY_SECONDS = 2

const _ACTION_POINTS_COST = {
	"attack": 2,
	"critical": 3,
	"heal": 1,
	"defend": 1
}

const _SKILL_POINTS_COST = {
	"vampire": 7,
	"bash": 5
}

var _action_resolver = preload("res://Scripts/Battle/ActionResolver.gd").new()
var _player = preload("res://Entities//Battle/BattlePlayer.gd").new()
var _monster_data = {}
#var _multiplier = 0
var _actions_left = 0 # points
var _correct_consecutive_tiles_picked = 0

var _last_action_picked = "" # eg. attack
var _times_last_action_picked = 0 # eg. 5 consecutive times

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
		
	# Panels themselves, not children, are 50% transparent
	self._set_background_image(map_type, variation)
	self._set_recall_tile_image(map_type, variation)
	
	$ActionsPanel.self_modulate = Color(1, 1, 1, 0.5)
	$SkillsPanel.self_modulate = Color(1, 1, 1, 0.5)
	
	var image_name = self._monster_data["type"].replace(' ', '')
	$MonsterControls/MonsterHealth.max_value = self._monster_data["max_health"]
	$MonsterControls/MonsterSprite.texture = load("res://assets/images/monsters/" + image_name + ".png")
	$PlayerControls/PlayerHealth.max_value = self._player.max_health
	
	$RecallGrid.battle_player = self._player
	$RecallGrid.connect("picked_all_tiles", self, "_on_picked_all_tiles")
	$RecallGrid.connect("correct_selected", self, "_on_correct_selected")
	$RecallGrid.connect("incorrect_selected", self, "_on_incorrect_selected")
	
	if not Features.is_enabled("defend action"):
		$ActionsPanel/Controls/DefendButton.visible = false
	
	self._update_health_displays()
	$StatusLabel.text = ""
	$NextTurnButton.visible = false
	self._start_next_turn()
	
	_player.connect("poison_damaged", self, "_on_poison_damaged")
	
	if not Features.is_enabled("tech_points"):
		$TechPointsLabel.visible = false
	
	self._disable_unusable_skills()

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
	
	$ActionsPanel/ActionsLabel.text = "Actions: " + str(_actions_left)

func _on_picked_all_tiles():
	var num_right = $RecallGrid.selected_right
	
#	if Features.is_enabled("multiplier_on_num_right"):
#		self._multiplier = pow(_MULTIPLIER_BASE, num_right)
#	else:
#		self._multiplier = 1
		
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
	
	# Start multiplier based on picking the same action consecutively
	if action == self._last_action_picked:
		self._times_last_action_picked += 1
	else:
		self._times_last_action_picked = 1
	self._last_action_picked = action
		
	var multiplier = pow(_MULTIPLIER_BASE, self._times_last_action_picked - 1)
	# End multiplier
	
	self._resolve_action(action, multiplier)
	
	if self._actions_left == 0: 
		$ActionsPanel/Controls.visible = false
		$NextTurnButton.visible = true

func _on_player_skill(skill):
	var tech_points_cost = _SKILL_POINTS_COST[skill]
	Globals.player_data.spend_tech_points(tech_points_cost)
	self._resolve_action(skill, 1)
	self._disable_unusable_skills()
	
# Common to attack/item/etc. and skills
func _resolve_action(action, multiplier):
	var message = self._action_resolver.resolve(action, self._player, self._monster_data, multiplier)
	$StatusLabel.text = message
	self._update_health_displays()
	
	if self._monster_data["health"] <= 0:
		self._show_battle_end(true)

func _resolve_monster_turn():
	var num_turns = self._monster_data["next_round_turns"]
	
	for i in range(num_turns):
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
	self._last_action_picked = ""
	self._times_last_action_picked = 0
	self._correct_consecutive_tiles_picked = 0
	
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
	
	self._correct_consecutive_tiles_picked += 1
	if self._correct_consecutive_tiles_picked >= 3:
		Globals.player_data.add_tech_point()
		$SkillsPanel/TechPointsLabel.text = "{points} tech points".format({points = Globals.player_data.tech_points})
		self._disable_unusable_skills()

func _on_incorrect_selected():
	self._correct_consecutive_tiles_picked = 0

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

func _on_VampireButton_pressed():
	self._on_player_skill("vampire")
	self._disable_unusable_skills()

func _on_BashButton_pressed():
	self._on_player_skill("bash")
	self._disable_unusable_skills()

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

# Poorly named. Enables if usable, disables otherwise
func _disable_unusable_skills():
	self._enable_action_button($SkillsPanel/VampireButton)
	self._enable_action_button($SkillsPanel/BashButton)
	
	if Globals.player_data.tech_points < _SKILL_POINTS_COST["vampire"]:
		self._disable_action_button($SkillsPanel/VampireButton)
	if Globals.player_data.tech_points < _SKILL_POINTS_COST["bash"]:
		self._disable_action_button($SkillsPanel/BashButton)

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


