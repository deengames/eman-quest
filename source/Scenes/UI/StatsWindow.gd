extends WindowDialog

func _ready():
	$LevelLabel.text = "Level: " + str(Globals.player_data.level)
	$ExpLabel.text = "XP: " + (str(Globals.player_data.experience_points) +
		"/" + str(Globals.player_data.get_next_level_xp()))