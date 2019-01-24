extends "StaticMap.gd"

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")
const StreamlinedRecallBattleScene = preload("res://Scenes/Battle/StreamlinedRecall/StreamlinedRecallBattleScene.tscn")

const map_type = "Final"
const variation = "Normal" # used for battleback
const _GLOW_TIME_SECONDS = 3

var _showed_final_events = false

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	
	if Globals.bosses_defeated < 3:
		self.remove_child($FinalEventsTrigger)
		self.remove_child($Jinn)
		self.remove_child($Umayyah)

func _on_FinalEventsTrigger_body_entered(body):
	if body == Globals.player and not self._showed_final_events:
		self._showed_final_events = true
		
		var player = Globals.player
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
			["???", "This mortal body ... is mine! I am free!!"],
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		yield(self._pause(1), "completed")
		$Umayyah.face_down()
		yield(self._pause(1), "completed")
		
		dialog_window = self._create_dialog_window(current_scene)
		dialog_window.show_texts([
			["???", "You will perish, human!"],
			["Hero", "What ... are you ... ?"],
			["Hero", "Ya Allah ... help me to destroy this monster!"]
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		yield(self._pause(1), "completed")
		player.unfreeze() # not really necessary. He will never walk again.
		
		var battle_scene = StreamlinedRecallBattleScene.instance()
		battle_scene.set_monster_data(Globals.quest.final_boss_data)
		SceneManagement.change_scene_to(body.get_tree(), battle_scene)

func _glow_and_pause(target):
	target.glow(_GLOW_TIME_SECONDS)
	yield(target, "done")

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