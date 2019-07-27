extends "StaticMap.gd"

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const StreamlinedRecallBattleScene = preload("res://Scenes/Battle/StreamlinedRecall/StreamlinedRecallBattleScene.tscn")
const TweenHelper = preload("res://Scripts/TweenHelper.gd")

const map_type = "Final"
const _GLOW_TIME_SECONDS = 3

func _ready():
	var player = Globals.player
	# https://www.pivotaltracker.com/story/show/164848304
	# Somehow, setting player position doesn't apply unless we change it here.
	# It looks like a Godot bug. Ya know what I'm talkin' about. Traced all the places
	# where we change the player's position, and none of them are incorrect. Somehow,
	# even when frozen, she just ends up going to the location specified here. ?????
	if Globals.pre_battle_position != null:
		player.position = Vector2(Globals.pre_battle_position[0], Globals.pre_battle_position[1])
	else:
		player.position = $Locations/Entrance.position
		
	# If we just slew the final boss, show correct post-victory events.
	if Globals.beat_last_boss and Globals.current_monster_type == "Mufsid":
		Globals.current_monster_type = "" # don't show again
		self._show_endgame_events()
	# If we aren't ready, don't show the final boss
	elif Globals.bosses_defeated < 3 or Globals.beat_last_boss:
		self.remove_child($FinalEventsTrigger)
		self.remove_child($Jinn)
		self.remove_child($Umayyah)
	elif Globals.showed_final_events:
		self.remove_child($Jinn)
	
	if not Globals.is_testing:
		_audio_bgs.play_sound("waterfall-cliff")
	

func _on_FinalEventsTrigger_body_entered(body):
	var player = Globals.player
	 # not sure why it's true, causes player to walk around during these cutscenes
	Globals.unfreeze_player_in_process = false
	
	if body == player and not Globals.showed_final_events:
		Globals.showed_final_events = true
		player.freeze()
		
		var root = get_tree().get_root()
		var current_scene = SceneManagement.get_current_scene(root)
		
		yield(self._pause(1), "completed")
		
		var dialog_window = self._create_dialog_window(current_scene)
		dialog_window.show_texts([
			["Umayyah", "O great Jinn Master! As promised, I brought the sacrifice ... !"],
			["???", "..."],
			["Umayyah", "Fwahaha! Power, is mine!!"],
			["???", "..."],
			["???", "Fool ..."],
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		self._glow_and_pause($Jinn)
		
		dialog_window = self._create_dialog_window(current_scene)
		dialog_window.show_texts([
			["Umayyah", "Master ... ?!"]
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		self._jinn_charges()
		yield(self._pause(0.5), "completed")
		$Jinn.visible = false
		AudioManager.new().play_sound("merge")
		self._glow_and_pause($Umayyah)
		
		# TODO: Lighting-bolt sound / flash screen
		yield(self._pause(2), "completed")
		
		dialog_window = self._create_dialog_window(current_scene)
		dialog_window.show_texts([
			["???", "..."],
			["???", "At last ..."],
			["???", "This mortal body ... is mine! I, Mufsid, am free to rain destruction!!"],
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		yield(self._pause(1), "completed")
		$Umayyah.face_down()
		yield(self._pause(1), "completed")
		
		dialog_window = self._create_dialog_window(current_scene)
		dialog_window.show_texts([
			["Mufsid", "You will perish, human!"],
			[Globals.PLAYER_NAME, "What ... are you ... ?"],
			[Globals.PLAYER_NAME, "Ya Allah ... help me to destroy this monster!"]
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		yield(self._pause(1), "completed")
		player.unfreeze() # not really necessary. He will never walk again.
	
	# If respawn here after battle, don't re-trigger battle
	if player.can_fight():
		# https://trello.com/c/4zj0dLpy/95-post-final-battle-crashes
		# Set transition_used to null, indicating to SceneManagement that we need to
		# spawn here after the battle concludes
		Globals.transition_used = null
		SceneManagement.start_battle(body.get_tree(), Globals.quest.final_boss_data)


func _show_endgame_events():
	self.remove_child($FinalEventsTrigger)
	$Jinn.visible = false
	$Jinn.position = $Umayyah.position
	$Umayyah.face_down()
	
	# https://trello.com/c/TroyNjSK/35-minor-bugs
	# Freeze forces the player to face down here. Not sure why (default direction?)
	# Change animation then pause for epsilon time, *then* freeze. DONE.
	Globals.player._on_facing_new_direction("Up")
	yield(self._pause(0.01), "completed")
	
	Globals.player.freeze()
	
	var root = get_tree().get_root()
	var current_scene = SceneManagement.get_current_scene(root)
		
	yield(self._pause(1), "completed")
		
	var dialog_window = self._create_dialog_window(current_scene)
	dialog_window.show_texts([
		["Mufsid", "..."],
		["Mufsid", "Pathetic ..."],
		["Mufsid", "This puny human vessel cannot command the full extent of my powers ..."],
		[Globals.PLAYER_NAME, "..."],
		["Mufsid", "I must find another ..."],
	])
	yield(dialog_window, "shown_all")
	dialog_window.queue_free()
	
	yield(self._pause(1), "completed")
	
	# 3s glow; 1s umayyah, 1s jinn, 1s jinn post-move
	self._glow_and_pause($Umayyah)
	yield(self._pause(1), "completed")
	
	$Jinn.visible = true
	AudioManager.new().play_sound("unmerge")
	self._glow_and_pause($Jinn)
	yield(self._pause(1), "completed")
	
	$Umayyah.become_normal()
	$Jinn.position.y -= 2 * Globals.TILE_HEIGHT
	yield(self._pause(1), "completed")
	
	var tween_helper = TweenHelper.new().fade_out(current_scene, $Jinn, 1)
	self.add_child(tween_helper)
	AudioManager.new().play_sound("teleport")
	tween_helper.start()
	yield(self._pause(1), "completed")

	dialog_window = self._create_dialog_window(current_scene)
	dialog_window.show_texts([
		["Umayyah", "What ... happened? Where am I?"],
		[Globals.PLAYER_NAME, "..."],
		[Globals.PLAYER_NAME, "It looks like you were under the control of a powerful jinn."],
		["Umayyah", "... The Great Master ... controlled me?"],
		["Umayyah", "..."]
	])
	yield(dialog_window, "shown_all")
	dialog_window.queue_free()
	yield(self._pause(1), "completed")
	
	dialog_window = self._create_dialog_window(current_scene)
	dialog_window.show_texts([
		["Umayyah", "Jinns ... it was a mistake to get involved with them."],
		[Globals.PLAYER_NAME, "I hope you learned your lesson. My parents got hurt."],
		["Umayyah", "I'm sorry ..."],
		[Globals.PLAYER_NAME, "I'd better get home. Baba and Mama are probably worried."]
	])
	yield(dialog_window, "shown_all")
	dialog_window.queue_free()
	
	Globals.player.unfreeze() # not needed


# Doesn't actually pause
func _glow_and_pause(target):
	target.glow(_GLOW_TIME_SECONDS)
	yield(target, "done") # doesn't actually pause

func _pause(seconds):
	yield(get_tree().create_timer(seconds), 'timeout')

# Jinns don't *charge*, they *teleport*. At least, in this game.
func _jinn_charges():
	$Jinn.visible = false
	# play sound
	$Jinn.position.y = 395
	$Jinn.visible = true
	# play sound

func _create_dialog_window(current_scene):
	var dialog_window = DialogueWindow.instance()
	current_scene.get_node("CanvasLayer").add_child(dialog_window)
	return dialog_window