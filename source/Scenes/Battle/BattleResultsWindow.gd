extends WindowDialog

const ReferenceChecker = preload("res://Scripts/ReferenceChecker.gd")

func _ready():
	self.popup_exclusive = true
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
		
		# Was a boss. Probably...
		if Globals.battle_spoils != null:
			$SpoilsText.text = "Found a " + Globals.battle_spoils.item_name
			$SpoilsText.visible = true
			Globals.player_data.key_items.append(Globals.battle_spoils)
			Globals.battle_spoils = null
			Globals.bosses_defeated += 1
		
		if monster_data["type"] == Globals.quest.final_boss_data.type:
			Globals.beat_last_boss = true
	
func _on_CloseButton_pressed():
	self.emit_signal("popup_hide")
	Globals.emit_battle_over_after_fade = true

func _on_WindowDialog_popup_hide():
	# On close
	if Globals.current_map != null:
		SceneManagement.change_map_to(get_tree(), Globals.current_map)
		var restore_position = Globals.pre_battle_position
		Globals.post_fade_position = Vector2(restore_position[0], restore_position[1])
		
		# For boss battle, or Hamza training battle, if we just lost, don't re-battle immediately.
		# pre_battle_position null check: makes sure player is not disposed		
		if (not Globals.won_battle or Globals.current_map_type == "Home") and not ReferenceChecker.is_previously_freed(Globals.player):
			Globals.player.temporarily_no_battles()
	else:
		# One-off battle
		get_tree().change_scene('res://Scenes/Title.tscn')