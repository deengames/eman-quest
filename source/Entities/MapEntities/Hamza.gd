extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const ChoicePanel = preload("res://Scenes/UI/ChoicePanel.tscn")
const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")

const BATTLE_DATA = {
	"type": "Hamza",
	"health": 250,
	"strength": 25,
	"defense": 15,
	"turns": 1,
	"experience points": 50,
	
	"skill_probability": 40,
	"skills": {
		"chomp": 60,
		"roar": 40,
	},
	"skill_messages": {
		"roar": "growls and raises his hackles!"
	},
}

func _on_Area2D_body_entered(body):
	# can_fight: after victory/defeat, don't re-trigger immediately
	if body == Globals.player and Globals.player.can_fight():
		
		Globals.player.freeze()
		var root = get_tree().get_root()
		var current_scene = SceneManagement.get_current_scene(root)
		
		AudioManager.new().play_sound("dog-barking")
		
		var dialog_window = DialogueWindow.instance()
		
		current_scene.get_node("CanvasLayer").add_child(dialog_window)
		var viewport = get_viewport_rect().size
		dialog_window.position = viewport / 4
	
		dialog_window.show_texts([
			["Hamza", "Woof!"],
			[Globals.PLAYER_NAME, "Hamza, you're too old to protect Mama and Baba ..."],
			[Globals.PLAYER_NAME, "I'm never too old to play-fight with you though!"]
		])
		yield(dialog_window, "shown_all")
		dialog_window.queue_free()
		
		var choice_panel = ChoicePanel.instance()
		current_scene.get_node("CanvasLayer").add_child(choice_panel)
		
		choice_panel.connect("on_yes", self, "_train_with_hamza")
		choice_panel.connect("on_no", self, "_unfreeze_player")
		choice_panel.show_text("Train with Hamza?", "Yes", "Maybe later")
		
func _train_with_hamza():
	self._unfreeze_player()
	SceneManagement.start_battle(get_tree(), BATTLE_DATA)
	
func _unfreeze_player():
	Globals.player.unfreeze()