extends WindowDialog

func _ready():
	self.popup_exclusive = true
	self._update_stats_display()
	
	$Stats/Labels/LevelLabel.text = "Level: " + str(Globals.player_data.level)
	
	$Stats/Labels/ExpLabel.text = "XP: " + (str(Globals.player_data.experience_points) +
		"/" + str(Globals.player_data.get_next_level_xp()))
		
	var weapon = Globals.player_data.weapon
	var armour = Globals.player_data.armour
	
	$Equipment/WeaponLabel.text = "Current weapon:\n" + weapon.str()
	$Equipment/ArmourLabel.text = "Current armour:\n" + armour.str()

func _on_UnassignHealthButton_pressed():
	self._unassign_point("health")

func _on_AssignHealthButton_pressed():
	self._assign_point("health")

func _on_UnassignStrengthButton_pressed():
	self._unassign_point("strength")

func _on_AssignStrengthButton_pressed():
	self._assign_point("strength")

func _on_UnassignDefenseButton_pressed():
	self._unassign_point("defense")

func _on_AssignDefenseButton_pressed():
	self._assign_point("defense")

func _on_UnassignActionsButton_pressed():
	self._unassign_point("num_actions")

func _on_AssignActionsButton_pressed():
	self._assign_point("num_actions")


func _assign_point(type):
	if Globals.player_data.unassigned_stats_points > 0:
		Globals.player_data.assigned_points[type] += 1
		Globals.player_data.unassigned_stats_points -= 1
		
		if type == "health": Globals.player_data.health += 1
		elif type == "strength": Globals.player_data.strength += 1
		elif type == "defense": Globals.player_data.defense += 1
		elif type == "num_actions": Globals.player_data.added_actions_point()
	
	self._update_stats_display()

func _unassign_point(type):
	if Globals.player_data.assigned_points[type] > 0:
		Globals.player_data.assigned_points[type] -= 1
		Globals.player_data.unassigned_stats_points += 1
		
		if type == "health": Globals.player_data.health -= 1
		elif type == "strength": Globals.player_data.strength -= 1
		elif type == "defense": Globals.player_data.defense -= 1
		elif type == "num_actions": Globals.player_data.removed_actions_point()
	
	self._update_stats_display()
	
func _update_stats_display():
	$Stats/Labels/StatsHeaderLabel.text = ("Stats                  Points" +
	" (" + str(Globals.player_data.unassigned_stats_points) +
	" unused)")
	
	$Stats/Labels/StatsLabel.text = ("Health: " + str(Globals.player_data.health) + "\n\n" +
		"Strength: " + str(Globals.player_data.strength) + "\n\n" + 
		"Defense: " + str(Globals.player_data.defense) + "\n\n" +
		"Actions: " + str(Globals.player_data.num_actions) + "\n\n"
	)
	
	$Stats/Labels/PointsAssignedLabel.text = (str(Globals.player_data.assigned_points["health"]) + "\n\n" +
		str(Globals.player_data.assigned_points["strength"]) + "\n\n" +
		str(Globals.player_data.assigned_points["defense"]) + "\n\n" +
		str(Globals.player_data.assigned_points["num_actions"])
	)