extends WindowDialog

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	if not Globals.won_battle:
		$ResultBanner.text = "Defeat!"
		$ExpGainBanner.visible = false
		$LevelText.visible = false

func initialize(monster_data):
	if Globals.won_battle:
		var xp_gained = monster_data["experience points"]
		Globals.player_data.gain_xp(xp_gained)
		$ExpGainBanner.text = "Gained " + str(xp_gained) + " experience!"
		$LevelText.text = "Level: " + str(Globals.player_data.level)
		$LevelText.text += "\n" + (str(Globals.player_data.experience_points) +
			"/" + str(Globals.player_data.get_next_level_xp()) + " XP")

func _on_CloseButton_pressed():
	if Globals.current_map != null:
		SceneManagement.change_map_to(get_tree(), Globals.current_map.map_type)
		Globals.player.position.x = Globals.pre_battle_position[0]
		Globals.player.position.y = Globals.pre_battle_position[1]
	else:
		# One-off battle
		get_tree().change_scene('res://Scenes/Title.tscn')
