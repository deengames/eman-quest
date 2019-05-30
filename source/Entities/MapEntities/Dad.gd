extends KinematicBody2D

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const Quest = preload("res://Entities/Quest.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		Globals.player.freeze()
		
		var texts = Quest.POST_BOSS_CUTSCENES[Globals.bosses_defeated]
		var root = get_tree().get_root()
		var current_scene = SceneManagement.get_current_scene(root)
		var dialog_window = DialogueWindow.instance()
		current_scene.add_child(dialog_window)
		
		var viewport = get_viewport_rect().size
		dialog_window.position = viewport / 4
			
		dialog_window.show_texts(texts)
		dialog_window.connect("shown_all", self, "_unfreeze_player")
	
func _unfreeze_player():
	Globals.player.unfreeze()