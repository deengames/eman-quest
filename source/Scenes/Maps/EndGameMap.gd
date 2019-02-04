extends "StaticMap.gd"

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const StreamlinedRecallBattleScene = preload("res://Scenes/Battle/StreamlinedRecall/StreamlinedRecallBattleScene.tscn")
const TweenHelper = preload("res://Scripts/TweenHelper.gd")

const map_type = "Final"
const _GLOW_TIME_SECONDS = 3

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	
	# If we just slew the final boss, show correct post-victory events.
	if Globals.beat_last_boss and Globals.current_monster_type == "FinalBoss":
		Globals.current_monster_type = "" # don't show again
		self._show_endgame_events()
	# If we aren't ready, don't show the final boss
	elif Globals.bosses_defeated < 3 or Globals.beat_last_boss:
		self.remove_child($FinalEventsTrigger)
		self.remove_child($Jinn)
		self.remove_child($Umayyah)
	elif Globals.showed_final_events:
		self.remove_child($Jinn)

func _on_FinalEventsTrigger_body_entered(body):
	var player = Globals.player
	
	if body == player and not Globals.showed_final_events:
		Globals.showed_final_events = true
		player.freeze()
		
		var root = get_tree().get_root()
		var current_scene = root.get_child(root.get_child_count() - 1)
		
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
			["Hero", "What ... are you ... ?"],
			["Hero", "Ya Allah ... help me to destroy this monster!"]
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		yield(self._pause(1), "completed")
		player.unfreeze() # not really necessary. He will never walk again.
		
	if player.can_fight():
		# Restore position after battle
		Globals.pre_battle_position = [player.position.x, player.position.y]
		Globals.current_monster_type = "FinalBoss"
		var battle_scene = StreamlinedRecallBattleScene.instance()
		battle_scene.set_monster_data(Globals.quest.final_boss_data)
		SceneManagement.change_scene_to(body.get_tree(), battle_scene)


func _show_endgame_events():
	Globals.player.freeze()
	
	self.remove_child($FinalEventsTrigger)
	$Jinn.visible = false
	$Jinn.position = $Umayyah.position
	$Umayyah.face_down()
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
		
	yield(self._pause(1), "completed")
		
	var dialog_window = self._create_dialog_window(current_scene)
	dialog_window.show_texts([
		["Mufsid", "..."],
		["Mufsid", "Pathetic ..."],
		["Mufsid", "This puny human vessel cannot command the full extent of my powers ..."],
		["Hero", "..."],
		["Mufsid", "I must find another ..."],
	])
	yield(dialog_window, "shown_all")
	dialog_window.queue_free()
	
	yield(self._pause(1), "completed")
	
	# 3s glow; 1s umayyah, 1s jinn, 1s jinn post-move
	self._glow_and_pause($Umayyah)
	yield(self._pause(1), "completed")
	
	$Jinn.visible = true
	self._glow_and_pause($Jinn)
	yield(self._pause(1), "completed")
	
	$Umayyah.become_normal()
	$Jinn.position.y -= 3 * Globals.TILE_HEIGHT
	yield(self._pause(1), "completed")
	
	var tween_helper = TweenHelper.new().fade_out(current_scene, $Jinn, 1)
	self.add_child(tween_helper)
	tween_helper.start()
	yield(self._pause(1), "completed")

	dialog_window = self._create_dialog_window(current_scene)
	dialog_window.show_texts([
		["Umayyah", "What ... happened? Where am I?"],
		["Hero", "..."],
		["Hero", "It looks like you were under the control of a powerful jinn."],
		["Umayyah", "... The Great Master ... controlled me?"],
		["Umayyah", "..."]
	])
	yield(dialog_window, "shown_all")
	dialog_window.queue_free()
	yield(self._pause(1), "completed")
	
	dialog_window = self._create_dialog_window(current_scene)
	dialog_window.show_texts([
		["Umayyah", "Jinns ... it was a mistake to get involved with them."],
		["Hero", "I hope you learned your lesson. My parents got hurt."],
		["Umayyah", "I'm sorry ..."],
		["Hero", "I'd better get home. Baba and Mama are probably worried."]
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
	current_scene.add_child(dialog_window)
	return dialog_window