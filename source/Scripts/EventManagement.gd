extends Node2D

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")

signal events_done

var _tree
var _post_fight_events

func _init(tree):
	self._tree = tree

func show_prebattle_events(monster):
	if "events" in monster and monster.events != null and len(monster.events) > 0:
		if monster.events.has("pre-fight"):
			
			Globals.player.freeze()
			
			var current_scene = self._get_current_scene()
			var dialog_window = self._create_dialog_window(current_scene)
			
			for event in monster.events["pre-fight"]:
				var yield_event = self._process_event(dialog_window, event)
				if yield_event != null:
					yield(dialog_window, yield_event)
				
			Globals.player.unfreeze()
			current_scene.remove_child(dialog_window)
			self.emit_signal("events_done", monster)
		
		if monster.events.has("post-fight"):
			Globals.connect("battle_over", self, "_on_battle_over")
			self._post_fight_events = monster.events["post-fight"]
	else:
		# Also emits immediately so consumers don't need to care if there are any events or not
		self.emit_signal("events_done", monster)

###
# Process a single event, like a message.
###
func _process_event(dialog_window, event):
	if event.has("messages"):
		# Pause here until we get "shown all" signal
		dialog_window.show_texts(event["messages"])
		return "shown_all"

func _on_battle_over():
	if Globals.won_battle:
		Globals.player.freeze()
		
		var current_scene = self._get_current_scene()
		var dialog_window = self._create_dialog_window(current_scene)
		
		for event in self._post_fight_events:
			var yield_event = self._process_event(dialog_window, event)
			if yield_event != null:
				yield(dialog_window, yield_event)
				
		Globals.player.unfreeze()
		current_scene.remove_child(dialog_window)

func _create_dialog_window(current_scene):
	var dialog_window = DialogueWindow.instance()
	current_scene.add_child(dialog_window)
	return dialog_window

func _get_current_scene():
	var root = self._tree.get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	return current_scene