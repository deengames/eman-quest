extends Node

const BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
const _SHOCK_TURNS = 2
const _HARDEN_DEFENSE_MULTIPLIER = 1.2 # harden => defense *= Nx eg. 1.2x
const _ROAR_BOOST_AMOUNT = 5 # roar => attack up by this amount
const _HEAL_PERCENT = 0.2 # 0.2 = 20% of max health

func _ready():
	pass

# player actions
func resolve(action, player, monster_data, multiplier):
	var monster_name = monster_data["type"]
	
	if not Features.is_enabled("actions require energy") or (
		Features.is_enabled("actions require energy") and player.detract_energy(action)):
		# We had enough energy to do this action
		if action == "attack":
			var damage = max(0, player.total_strength() - monster_data["defense"])
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			return "Hero attacks for " + str(damage) + " damage!"
		elif action == "critical":
			var damage = max(0, floor(1.5 * player.total_strength()) - monster_data["defense"])
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
			var damage = max(0, player.total_strength()) # ignores defense
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			player.heal(damage)
			return "Hero hits/absorbs " + str(damage) + "!"
		elif action == "bash":
			monster_data["next_round_turns"] -= 1
			var damage = max(0, (player.total_strength() * 2) - monster_data["defense"])
			damage = ceil(damage * multiplier)
			monster_data["health"] -= damage
			return "Hero bashes for " + str(damage) + "!\n" + monster_name + " loses a turn!"
		elif action == "energy":
			return "Gained " + str(BattlePlayer.ENERGY_GAIN_PER_ACTION) + " energy!"
		
func monster_attacks(monster_data, player, boost_amount, memory_grid):
	
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
		
		var result = self._process_attack(to_use, monster_data, player, boost_amount, memory_grid)
		var pre_boost_damage = result["damage"]
		# Reduce damage by 10% per successful boost
		var boost_block_percent = max(0, 1 - (0.1 * boost_amount))
		var damage = floor(pre_boost_damage * boost_block_percent)
		var message = result["message"]
		
		if damage > 0:
			player.damage(damage)
			
		return message
		
func _process_attack(action, monster_data, player, boost_amount, memory_grid):
	var damage = 0
	var monster_name = monster_data["type"]
	var message = monster_name + " "
	
	if action == "attack":
		damage = max(0, monster_data["strength"] - player.total_defense())
		message += "attacks for " + str(damage) + " damage."
	elif action == "chomp":
		damage = max(0, (2 * monster_data["strength"]) - player.total_defense())
		message += "CHOMPS! " + str(damage) + " damage!"
	elif action == "shock":
		damage = monster_data["strength"] # pierces defense
		message += "shocks you for " + str(damage) + "!"
		if memory_grid != null: # null on fast-paced battle grid
			memory_grid.shock(_SHOCK_TURNS)
	elif action == "freeze":
		# Shock, but a few tiles only
		damage = monster_data["strength"] # pierces defense
		message += "freezes you! " + str(damage) + " damage!"
		if memory_grid != null: # null on fast-paced battle grid
			memory_grid.freeze(_SHOCK_TURNS, 5)
	elif action == "vampire":
		var multiplier = 1.5
		if "vampire multiplier" in monster_data:
			multiplier = monster_data["vampire multiplier"]
		damage = floor(monster_data["strength"] * multiplier)
		message += "hits/absorbs " + str(damage) + " health!"
		monster_data["health"] += damage
		# Don't allow overhealing. Bats are nigh unto impossible to kill otherwise.
		monster_data["health"] = min(monster_data["health"], monster_data["max_health"])
	elif action == "harden":
		# Hard to balance without knowing monster profile. This is easy: boost by a small percentage.
		# If used enough times, has a good effect. Yet, doesn't drastically change it's toughness.
		monster_data["defense"] *= _HARDEN_DEFENSE_MULTIPLIER
		message += "hardens! Defense up!"
	elif action == "heal":
		var heal_amount = round(_HEAL_PERCENT * monster_data["max_health"])
		heal_amount = min(monster_data["max_health"] - monster_data["health"], heal_amount)
		monster_data["health"] += heal_amount
		message += " heals " + str(heal_amount) + " health."
	elif action == "roar":
		monster_data["strength"] += _ROAR_BOOST_AMOUNT
		message += "roars! Attack up by " + str(_ROAR_BOOST_AMOUNT) + "!"
		
	return { "damage": damage, "message": message }