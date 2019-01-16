extends Node2D

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")
const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")

signal events_done

const DEATH_TIME_SECONDS = 1.5

var _tree
var _post_fight_events

func _init(tree):
	self._tree = tree

"""
Shows pre-battle events for a monster. Also sets up post-battle events (if they exist).
"""
func show_prebattle_events(monster):
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
	
"""
Process a single event, like a message.
"""
func _process_event(dialog_window, event):
	if event.has("messages"):
		# Pause here until we get "shown all" signal
		dialog_window.show_texts(event["messages"])
		return "shown_all"
	elif event.has("die"):
		var target_name = event["die"]
		var target = null
		
		var children = self._get_current_scene().get_children()
		for child in children:
			if child.name == target_name:
				target = child
				break
		
		if target != null: # found the node to kill
			# Wait ~1.5s for this to complete
			var fluctuator = AlphaFluctuator.new(target)
			self._get_current_scene().add_child(fluctuator)
			# We can't yield here because we yield elsewhere. This is not done synchronously.
			# C'est la vie.
			fluctuator.run(DEATH_TIME_SECONDS)
			self.remove_child(target)
			self.remove_child(fluctuator)
		else:
			print("WARNING: Can't find node named {name} to kill off!".format({name = target_name}))
	else:
		print("Not sure how to process event: {e}".format({e = event}))
		assert(false)

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