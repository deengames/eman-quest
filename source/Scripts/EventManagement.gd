extends Node2D

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")
const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const FadeAndColour = preload("res://Scripts/Effects/FadeAndColour.gd")
const HomeMap = preload("res://Scenes/Maps/Home.tscn")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

signal events_done

const _EFFECT_TIME_SECONDS = 1.5

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
		Globals.current_map_scene.freeze_monsters()
		
		var current_scene = SceneManagement.get_current_scene(self._tree.get_root())
		var dialog_window = self._create_dialog_window(current_scene)
		
		for event in monster.events["pre-fight"]:
			var yield_event = self._process_event(dialog_window, event)
			if yield_event != null:
				yield(dialog_window, yield_event)
			
		Globals.player.unfreeze()
		current_scene.get_node("CanvasLayer").remove_child(dialog_window)
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
	elif event.has("die") or event.has("escape"):
		
		var key = ""
		if event.has("escape"):
			key = "escape"
		else:
			key = "die"
			
		var target_name = event[key]
		var target = null
		
		var current_scene = SceneManagement.get_current_scene(self._tree.get_root())
		var children = current_scene.get_children()
		for child in children:
			if child.name == target_name:
				target = child
				break
		
		if target != null: # found the node to kill
			# Wait ~1.5s for this to complete
			var effect
			if key == "escape":
				effect = FadeAndColour.new(target)
			else:
				effect = AlphaFluctuator.new(target)
				
			SceneManagement.get_current_scene(self._tree.get_root()).add_child(effect)
			# We can't yield here because we yield elsewhere. This is not done synchronously.
			# C'est la vie. This is a horrible crutch / work-around.
			effect.run(_EFFECT_TIME_SECONDS)
			effect.remove_on_done(current_scene, target)
		else:
			print("WARNING: Can't find node named {name} to {effect}!".format({name = target_name, effect = key}))
	else:
		print("Not sure how to process event: {e}".format({e = event}))
		if Globals.enable_assertions == true:
			assert(false)

func _on_battle_over():
	if Globals.won_battle:
		# Should technically go in pre-battle too, but, due to a bug, is only here
		# Can't put this in DialogWindow, events show multiple of them.
		Globals.is_dialog_open = true
		
		var current_scene = SceneManagement.get_current_scene(self._tree.get_root())
		var dialog_window = self._create_dialog_window(current_scene)
		
		Globals.player.freeze()
		Globals.current_map_scene.freeze_monsters()
		
		for event in self._post_fight_events:
			var yield_event = self._process_event(dialog_window, event)
			if yield_event != null:
				yield(dialog_window, yield_event)
				
		Globals.current_map_scene.unfreeze_monsters()
		current_scene.get_node("CanvasLayer").remove_child(dialog_window)
		
		# Don't repeat events after subsequent battles
		Globals.disconnect("battle_over", self, "_on_battle_over")
		
		# Go home after boss battle events
		var tree = current_scene.get_tree()

		SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
		yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
		SceneManagement.change_scene_to(tree, HomeMap.instance())
		SceneFadeManager.fade_in(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
				

func _create_dialog_window(current_scene):
	var dialog_window = DialogueWindow.instance()
	current_scene.get_node("CanvasLayer").add_child(dialog_window)
	
	var viewport = current_scene.get_viewport_rect().size
	dialog_window.position = viewport / 4
	
	return dialog_window