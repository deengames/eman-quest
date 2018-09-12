extends Node

const BattlePlayer = preload("res://Entities/BattlePlayer.gd")
const SHOCK_TURNS = 2

func _ready():
	pass

# player actions
func resolve(action, player, monster_data, multiplier):
	if not Features.is_enabled("actions require energy") or (
		Features.is_enabled("actions require energy") and player.detract_energy(action)):
		# We had enough energy to do this action
		if action == "attack":
			var damage = player.strength - monster_data["defense"]
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			return "Hero attacks for " + str(damage) + " damage!"
		elif action == "critical":
			var damage = floor(1.5 * player.strength) - monster_data["defense"]
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			return "CRITICAL hit for " + str(damage) + "!!!"
		elif action == "heal":
			var heal_amount = player.heal()
			heal_amount = ceil(heal_amount * multiplier)
			return "Healed " + str(heal_amount) + " health!"
		elif action == "defend":
			player.defend(multiplier)
			return "Hero double-downs on defense!"
		elif action == "vampire":
			var damage = player.strength # ignores defense
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			player.heal(damage)
			return "Hero hits/absorbs " + str(damage) + "!"
		elif action == "bash":
			monster_data["next_round_turns"] -= 1
			var damage = (player.strength * 2) - monster_data["defense"]
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			return "Hero bashes for " + str(damage) + "!\nMonster loses a turn!"
		elif action == "energy":
			return "Gained " + str(BattlePlayer.ENERGY_GAIN_PER_ACTION) + " energy!"
		
func monster_attacks(monster_data, player, memory_grid):
	
	var num_turns = Globals.randint(1, 3)
	for turn in num_turns:
		
		var use_skill = randi() % 100 <= monster_data["skill_probability"]
		var to_use = "attack"
		
		if use_skill:
			for skill in monster_data.skills.keys():
				var probability = monster_data.skills[skill]
				var skill_roll = randi() % 100
				if skill_roll <= probability:
					to_use = skill
					break
		
		var result = self._process_attack(to_use, monster_data, player, memory_grid)
		var damage = result["damage"]
		var message = result["message"]
		
		if damage > 0:
			player.damage(damage)
			
		return message
		
func _process_attack(action, monster_data, player, memory_grid):
	var damage = 0
	var message = ""
	
	if action == "attack":
		damage = max(0, monster_data["strength"] - player.total_defense())
		message = "Monster attacks for " + str(damage) + " damage!"
		return { "damage": damage, "message": message }
	elif action == "chomp":
		damage = max(0, (2 * monster_data["strength"]) - player.total_defense())
		message = "Monster CHOMPS! " + str(damage) + " damage!"
	elif action == "shock":
		damage = monster_data["strength"] # pierces defense
		message = "Monster shocks you! " + str(damage)
		memory_grid.shock(SHOCK_TURNS)
	elif action == "vampire":
		damage = floor(monster_data["strength"] * 1.5)
		message = "Monster hits/absorbs " + str(damage) + " HP!"
		monster_data["health"] += damage
	
	return { "damage": damage, "message": message }