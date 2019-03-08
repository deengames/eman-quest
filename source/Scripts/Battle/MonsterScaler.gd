extends Node

#####
# Scales monsters proportionally as the player levels up.
# Tries to strike a balance between monsters being challenging, yet
# defeatable. Key: if Slime Forest is dungeon #4, you still should struggle.
#
# Currently, algorithm uses the monster "data shape" as the base, and
# adds a fixed growth percentage per level (say, 20%).

# For example, say slime has 35 health, 10 strength, 5 defense (total=50).
# In this case, at each level, the slime gets +10 points (20% of 50).

# At level 1, we get 50 points, distributed as 35, 10, 5.
# At level 2, we get 60 points, distributed as 42, 12, 6 (1.2x)
# At level 10, we get 150 points, so it's 105, 30, 15. 
# Note the "shape" (high health, moderate attack, crap defense) stays the same.
###

const _GROWTH_PERCENT_PER_LEVEL = 0.1 # 0.2 = 20%

static func scale_monster_data(monster_data):
	var level_scale = Globals.player_data.level - 1 # no growth at level 1
	var base_health = monster_data["health"]
	var base_strength = monster_data["strength"]
	var base_defense = monster_data["defense"]
	
	var base_points = base_health + base_strength + base_defense
	var points_per_level = _GROWTH_PERCENT_PER_LEVEL * base_points
	var num_levels = level_scale
	var total_points = base_points + (points_per_level * num_levels)
	
	# TODO: keep precision here and round elsewhere, like damage calculations
	monster_data["health"] = floor(base_health * (total_points / base_points))
	monster_data["strength"] = floor(base_strength * (total_points / base_points))
	monster_data["defense"] = floor(base_defense * (total_points / base_points))
	monster_data["level"] = level_scale + 1 # show 1, 2, ...
	
	var base_exp = monster_data["experience points"]
	var total_exp = base_exp + floor(_GROWTH_PERCENT_PER_LEVEL * level_scale * base_exp)
	monster_data["experience points"] = total_exp