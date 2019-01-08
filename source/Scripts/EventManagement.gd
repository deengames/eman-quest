extends Node2D

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")

signal events_done

func show_prebattle_events(tree, monster):
	if "events" in monster and monster.events != null and len(monster.events) > 0:
		if monster.events.has("pre-fight"):
			Globals.player.freeze()
			var dialog_window = DialogueWindow.instance()
			
			var root = tree.get_root()
			var current_scene = root.get_child(root.get_child_count() - 1)
			current_scene.add_child(dialog_window)
			
			for event in monster.events["pre-fight"]:
				if event.has("messages"):
					# Pause here until we get "shown all" signal
					dialog_window.show_texts(event["messages"])
					yield(dialog_window, "shown_all")
				
			Globals.player.unfreeze()
			current_scene.remove_child(dialog_window)
			self.emit_signal("events_done", monster)
	else:		
		# Also emits immediately so consumers don't need to care if there are any events or not
		self.emit_signal("events_done", monster)