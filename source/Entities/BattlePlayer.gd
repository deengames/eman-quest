extends Node

signal died

const HEAL_PERCENT = 0.2 # 0.2 = 20%
const DEFEND_MULTIPLIER = 1.5 # 1.5 => defend multiplies defense by 1.5x per action

var current_health = 0
var max_health = 0
var strength = 0
# max number of tiles to pick from the grid
var num_pickable_tiles = 0
# max number of actions to pick from picked tiles
var num_actions = 0
var _defense = 0
var _times_defending = 0

func _init(health = 60, strength = 5, defense = 3, num_pickable_tiles = 5, num_actions = 3):
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.current_health = health
	self.strength = strength
	self._defense = defense
	self.max_health = self.current_health
	self.num_pickable_tiles = num_pickable_tiles
	self.num_actions = num_actions

func heal(amount = 0):
	if amount == 0:
		amount = floor(self.max_health * HEAL_PERCENT)
	amount = min(amount, self.max_health - self.current_health)
	self.current_health += amount
	if self.current_health > self.max_health:
		self.current_health = self.max_health
	return amount

func defend():
	self._times_defending += 1

func reset():
	self._times_defending = 0

func total_defense():
	return floor(self._defense * pow(DEFEND_MULTIPLIER, self._times_defending))

func damage(damage):
	if damage > 0:
		self.current_health -= damage