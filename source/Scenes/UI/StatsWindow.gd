extends WindowDialog

func _ready():
	$LevelLabel.text = "Level: " + str(Globals.player_data.level)
	if Globals.player_data.unassigned_stats_points > 0:
		$LevelLabel.text += (" (" + str(Globals.player_data.unassigned_stats_points) +
		" unused stats points)")
	
	$ExpLabel.text = "XP: " + (str(Globals.player_data.experience_points) +
		"/" + str(Globals.player_data.get_next_level_xp()))