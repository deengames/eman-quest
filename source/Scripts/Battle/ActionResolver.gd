extends Node

const BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
const _SHOCK_TURNS = 2
const _HARDEN_DEFENSE_MULTIPLIER = 1.2 # harden => defense *= Nx eg. 1.2x
const _ROAR_BOOST_AMOUNT = 5 # roar => attack up by this amount
const _HEAL_PERCENT = 0.2 # 0.2 = 20% of max health
const _POISONED_TURNS = 3

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
			
			# Culmulative check. If we have three skills, with probability 50, 25, 25,
			# then rolling 0-49 uses the first one, 50-74 the second, 75-100 the third.
			# If we do three independent checks, the probability of the third or subsequent
			# skill becomes vanishingly small, because the first two skill checks both
			# have to fail.
			var skill_range = {} # skill => [lower, upper] bounds
			var total = 0
			
			# Calculate the total, eg. if skills are 30/20/10, total is 60
			for skill_probability in monster_data.skills.values():
				total += skill_probability
			
			var skill_roll = randi() % int(total)
			
			# Calculate upper/lower bounds for each skill
			total = 0
			for skill in monster_data.skills.keys():
				var probability = monster_data.skills[skill]
				var lower_bound = total
				var upper_bound = total + probability
				total += probability
				skill_range[skill] = [lower_bound, upper_bound]
				
				if skill_roll >= lower_bound and skill_roll < upper_bound:
					to_use = skill
					break
				
		 
		var result = self._process_attack(to_use, monster_data, player, boost_amount, memory_grid)
		var damage = result["damage"]
		var message = result["message"]
		
		if damage > 0:
			player.damage(damage)
			
		return message
		
func _process_attack(action, monster_data, player, boost_amount, memory_grid):
	var damage = 0
	var monster_name = monster_data["type"]
	# For custom messages
	var message # empty-string, soon to be the message suffix
	var amount # amount to place in custom message token {amount}
	
	if action == "attack":
		damage = max(0, monster_data["strength"] - player.total_defense())
		message = "attacks for " + str(damage) + " damage."
	elif action == "chomp":
		damage = max(0, (2 * monster_data["strength"]) - player.total_defense())
		message = "CHOMPS! " + str(damage) + " damage!"
	elif action == "shock":
		damage = monster_data["strength"] # pierces defense
		message = "shocks you for " + str(damage) + "!"
		if memory_grid != null: # null on fast-paced battle grid
			memory_grid.shock(_SHOCK_TURNS)
	elif action == "freeze":
		# Shock, but a few tiles only
		damage = monster_data["strength"] # pierces defense
		message = "freezes you, piercing your armour! " + str(damage) + " damage!"
		if memory_grid != null: # null on fast-paced battle grid
			memory_grid.freeze(_SHOCK_TURNS, 5)
	elif action == "vampire":
		var multiplier = 1.5
		if "vampire multiplier" in monster_data:
			multiplier = monster_data["vampire multiplier"]
		damage = floor(monster_data["strength"] * multiplier)
		message = "hits/absorbs " + str(damage) + " health!"
		monster_data["health"] += damage
		# Don't allow overhealing. Bats are nigh unto impossible to kill otherwise.
		monster_data["health"] = min(monster_data["health"], monster_data["max_health"])
	elif action == "harden":
		# Hard to balance without knowing monster profile. This is easy: boost by a small percentage.
		# If used enough times, has a good effect. Yet, doesn't drastically change it's toughness.
		monster_data["defense"] *= _HARDEN_DEFENSE_MULTIPLIER
		message = "hardens! Defense up!"
	elif action == "heal":
		amount = round(_HEAL_PERCENT * monster_data["max_health"])
		amount = min(monster_data["max_health"] - monster_data["health"], amount)
		monster_data["health"] += amount
		message = "heals " + str(amount) + " health."
	elif action == "roar":
		monster_data["strength"] += _ROAR_BOOST_AMOUNT
		message = "roars! Attack up by " + str(_ROAR_BOOST_AMOUNT) + "!"
		amount = str(_ROAR_BOOST_AMOUNT)
	elif action == "disable critical":
		message = "strikes! Critical attack disabled!"
		player.disable("critical")
	elif action == "disable attack":
		message = "strikes! Attack disabled!"
		player.disable("attack")
	elif action == "disable items":
		message = "strikes! Items disabled!"
		player.disable("items")
	elif action == "sleep":
		message = "puts you to sleep!"
		player.is_asleep = true
	elif action == "poison":
		player.poison(_POISONED_TURNS)
		message = "poisons you!"
	elif action == "armour break":
		message = "hits your armour, damaging it!"
		player.lower_defense()
		
	# Apply custom/override message if it exists
	if monster_data.has("skill_messages"):
		var override_messages = monster_data["skill_messages"]
		if override_messages.has(action):
			message = override_messages[action]
			# Replace tokens with values
			if amount != null:
				message = message.replace("{amount}", amount)
			message = message.replace("{damage}", damage)
			
	message = monster_name + " " + message
	
	return { "damage": damage, "message": message }