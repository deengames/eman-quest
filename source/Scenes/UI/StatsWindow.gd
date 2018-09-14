extends WindowDialog

func _ready():
	$LevelLabel.text = "Level: " + str(Globals.player_data.level)
	$ExpLabel.text = "Experience Points: " + str(Globals.player_data.experience_points)