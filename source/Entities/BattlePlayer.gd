extends Node

signal died

const HEAL_PERCENT = 0.2 # 0.2 = 20%
const DEFEND_MULTIPLIER = 1.5 # 1.5 => defend multiplies defense by 1.5x per action
const _ENERGY_PER_TURN = 1
const ENERGY_GAIN_PER_ACTION = 2

const _ACTION_ENERGY_COST = {
	"attack": 1,
	"critical": 8,
	"heal": 2,
	"defend": 0,
	"vampire": 15,
	"bash": 10,
	"energy": -1 * ENERGY_GAIN_PER_ACTION
}

var current_health = 0
var max_health = 0
var energy = 3
var max_energy = 0
var strength = 0
# max number of tiles to pick from the grid
var num_pickable_tiles = 0
# max number of actions to pick from picked tiles
var num_actions = 0
var _defense = 0
var _times_defending = 0

func _init(health = 60, strength = 7, defense = 5, num_pickable_tiles = 5, num_actions = 3, max_energy = 20):
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.current_health = health
	self.strength = strength
	self._defense = defense
	self.max_health = self.current_health
	self.num_pickable_tiles = num_pickable_tiles
	self.num_actions = num_actions
	self.max_energy = max_energy

func heal(amount = 0):
	if amount == 0:
		amount = floor(self.max_health * HEAL_PERCENT)
	amount = min(amount, self.max_health - self.current_health)
	self.current_health += amount
	if self.current_health > self.max_health:
		self.current_health = self.max_health
	return amount

func defend(multiplier):
	self._times_defending += 1 * floor(multiplier)

func reset():
	self.energy += _ENERGY_PER_TURN
	self.energy = min(self.energy, self.max_energy)
	self._times_defending = 0

func total_defense():
	return floor(self._defense * pow(DEFEND_MULTIPLIER, self._times_defending))

func damage(damage):
	if damage > 0:
		self.current_health -= damage

func detract_energy(action):
	# returns true if we had enough energy to do said action
	var cost = _ACTION_ENERGY_COST[action]
	
	if self.energy >= cost:
		self.energy -= cost
		return true
	else:
		return false