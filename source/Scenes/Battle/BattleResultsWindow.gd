extends WindowDialog

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	if not Globals.won_battle:
		$ResultBanner.text = "Defeat!"

func _on_CloseButton_pressed():
	if Globals.current_map != null:
		SceneManagement.change_map_to(get_tree(), Globals.current_map.map_type)
		Globals.player.position.x = Globals.pre_battle_position[0]
		Globals.player.position.y = Globals.pre_battle_position[1]
	else:
		# One-off battle
		get_tree().change_scene('res://Scenes/Title.tscn')
