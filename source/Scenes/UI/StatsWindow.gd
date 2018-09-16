extends WindowDialog

func _ready():
	self._update_stats_display()
	
	$LevelLabel.text = "Level: " + str(Globals.player_data.level)
	
	$ExpLabel.text = "XP: " + (str(Globals.player_data.experience_points) +
		"/" + str(Globals.player_data.get_next_level_xp()))

func _on_UnassignHealthButton_pressed():
	self._unassign_point("health")

func _on_AssignHealthButton_pressed():
	self._assign_point("health")

func _assign_point(type):
	if Globals.player_data.unassigned_stats_points > 0:
		Globals.player_data.assigned_points[type] += 1
		Globals.player_data.unassigned_stats_points -= 1
		
		if type == "health": Globals.player_data.health += 1
	
	self._update_stats_display()

func _unassign_point(type):
	if Globals.player_data.assigned_points[type] > 0:
		Globals.player_data.assigned_points[type] -= 1
		Globals.player_data.unassigned_stats_points += 1
		
		if type == "health": Globals.player_data.health -= 1
	
	self._update_stats_display()
	
func _update_stats_display():
	if Globals.player_data.unassigned_stats_points > 0:
		$StatsHeaderLabel.text = ("Stats                      Points Assigned" +
		" (" + str(Globals.player_data.unassigned_stats_points) +
		" unused)")
	
	$StatsLabel.text = ("Health: " + str(Globals.player_data.health) + "\n" +
		"Strength: " + str(Globals.player_data.strength) + "\n" + 
		"Defense: " + str(Globals.player_data.defense) + "\n" +
		"\n" +
		"Energy: " + str(Globals.player_data.max_energy) + "\n" +		
		"Tile Picks: " + str(Globals.player_data.num_pickable_tiles) + "\n" +
		"Actions: " + str(Globals.player_data.num_actions) + "\n"
	)
	
	$PointsAssignedLabel.text = (str(Globals.player_data.assigned_points["health"]) + "\n" +
		str(Globals.player_data.assigned_points["strength"]) + "\n" +
		str(Globals.player_data.assigned_points["defense"]) + "\n" +
		"\n" +
		str(Globals.player_data.assigned_points["num_pickable_tiles"]) + "\n" +
		str(Globals.player_data.assigned_points["num_actions"]) + "\n" +
		str(Globals.player_data.assigned_points["energy"])
	)