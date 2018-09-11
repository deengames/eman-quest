extends Node2D

const ActionButton = preload("res://Scenes/Battle/ActionButton.tscn")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

const MAX_MESSAGES = 12 # with wrap, 15 lines max, 10 -11is safe
# Pick N tiles to get a bonus for consecutive picks

var monster_data = {}

var player = preload("res://Entities//BattlePlayer.gd").new()
var _action_resolver = preload("res://Scripts/Battle/ActionResolver.gd").new()
var _consecutive_checker = preload("res://Scripts/Battle/ConsecutiveActionsChecker.gd").new()

var _action_buttons = []
var _history_messages = []
var _size = [5, 5]
var _advanced_mode = false
var _actions_picked = 0

func _ready():
	$MemoryGrid.initialize(_size[0], _size[1], _advanced_mode, self.player.num_pickable_tiles)
	$MemoryGrid.connect("all_tiles_picked", self, "_show_turn_options")
	$MemoryGrid.connect("tile_picked", self, "_check_for_consecutive_picks_bonus")
	self._consecutive_checker.connect("picked_consecutives", self, "_consecutive_tiles_bonus")
	$History.text = ""
	self._update_health_displays()

func go_turbo():
	# Advanced mode ENABLED.
	self._size = [8, 6]
	self._advanced_mode = true

func _check_for_consecutive_picks_bonus(action):
	self._consecutive_checker.action_picked(action)

func _consecutive_tiles_bonus(action):
	print("BONUS => " + action)

func _show_turn_options(tiles_picked):
	if len(tiles_picked) == 0:
		tiles_picked.append("attack")
		tiles_picked.append("defend")
	
	for tile in tiles_picked:
		var action_button = ActionButton.instance()
		action_button.initialize(tile)
		self.add_child(action_button)
		
		action_button.position.x = $MemoryGrid.position.x + (80 * len(self._action_buttons))
		action_button.position.y = $MemoryGrid.position.y + 16 + ($MemoryGrid.tiles_high * 64)
		
		action_button.connect("action_selected", self, "_on_action")
		
		self._action_buttons.append(action_button)

func _on_action(action_button):
	var message = self._action_resolver.resolve(action_button.action, self.player, self.monster_data)
	self._add_message(message)
	self._actions_picked += 1
	
	self._update_health_displays()
	
	if self.monster_data["health"] <= 0:
		self._show_battle_end(true)
	
	var index = self._action_buttons.find(action_button)
	if index > -1: # guaranteed
		self._action_buttons.remove(index)
	self.remove_child(action_button)
	action_button.queue_free()
	
	if len(self._action_buttons) == 0 or self._actions_picked == self.player.num_actions:
		self._finish_turn()
	
func _update_health_displays():
	$YourHpLabel.text = "Hero: " + str(self.player.current_health)
	$EnemyHpLabel.text = self.monster_data["type"] + ": " + str(self.monster_data["health"])

func _finish_turn():
	self._actions_picked = 0
	for action_button in self._action_buttons:
		self.remove_child(action_button)
		action_button.queue_free()
		
	self._action_buttons = []
	
	for n in range(self.monster_data["next_round_turns"]):
		var message = self._action_resolver.monster_attacks(self.monster_data, self.player, $MemoryGrid)
		self._add_message(message)
	
	self.monster_data["next_round_turns"] = self.monster_data["turns"]
	
	if self.player.current_health <= 0:
		self._add_message("Hero dies!")
		self._show_battle_end(false)
		
	# Round done
	self.player.reset()
	$MemoryGrid.reset()
	self._update_health_displays()

func _on_VictoryButton_pressed():
	if Globals.current_map != null:
		SceneManagement.change_map_to(get_tree(), Globals.current_map.map_type)
		Globals.player.position.x = Globals.pre_battle_position[0]
		Globals.player.position.y = Globals.pre_battle_position[1]
	else:
		# One-off battle
		get_tree().change_scene('res://Scenes/Title.tscn')

func _show_battle_end(is_victory):
	$VictoryButton.visible = true
	$MemoryGrid.visible = false
	Globals.won_battle = is_victory
	self._add_message("Hero vanquished the monster!")
	
	for button in self._action_buttons:
		self.remove_child(button)
		button.queue_free()
	if not is_victory:
		$VictoryButton.text = "Defeat!"

func _add_message(message):
	$History.text = ""
	
	self._history_messages.append(message)
	# trim
	while len(self._history_messages) > MAX_MESSAGES:
		self._history_messages.remove(0) # oldest first
	
	for message in self._history_messages:
		$History.text += message + "\n"
