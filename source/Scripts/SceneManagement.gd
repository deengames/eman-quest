extends Node

const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const AudioManager = preload("res://Scripts/AudioManager.gd")
const Boss = preload("res://Entities/Battle/Boss.gd")
const EndGameMap = preload("res://Scenes/Maps/EndGameMap.tscn")
const EventManagement = preload("res://Scripts/EventManagement.gd")
const HomeMap = preload("res://Scenes/Maps/Home.tscn")
const MapNameLabel = preload("res://Scenes/UI/MapNameLabel.tscn")
const Player = preload("res://Entities/Player.tscn")
const PlayerClass = preload("res://Entities/Player.gd")
const PopulatedMapScene = preload("res://Scenes/PopulatedMapScene.tscn")
const ReferenceChecker = preload("res://Scripts/ReferenceChecker.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const StreamlinedRecallBattleScene = preload("res://Scenes/Battle/StreamlinedRecall/StreamlinedRecallBattleScene.tscn")
const StaticMap = preload("res://Scenes/Maps/StaticMap.gd")
const TweenHelper = preload("res://Scripts/TweenHelper.gd")

# Polymorphic. Target can be a type (eg. "Forest/Death") or a submap.
static func change_map_to(tree, target, auto_save = true):
	### I ripped out the overworld. Here's a hack: if we're going there, go to the
	# area selection screen instead. It's bad, but saves me from reworking kilos
	# of code to rewire how this all works. Yes, there's some dead code left behind.
	###
	if typeof(target) == TYPE_STRING and target == "Overworld":
		SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
		yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
		tree.change_scene("res://Scenes/Maps/AreaSelect.tscn")
		# Above disposes player, hack Globals.player to be a non-disposed instance
		Player.instance()
		return
		
	# battle concluded on final map, which was GCed (null).
	# Transition_used == null is used to allow us to exit back to the world map from the final map
	if Globals.current_map_type == "Final" and Globals.transition_used == null:
		change_scene_to(tree, EndGameMap.instance())
	elif Globals.current_monster_type == "Hamza" and Globals.current_map_type == "Home":
		# Just fought Hamza, go home ... and don't get stuck there
		# (Without this, exiting home leads back to home.)
		Globals.current_monster_type = ""
		change_scene_to(tree, HomeMap.instance())
	else:
		_remove_monster_instances()
		
		var map_type = target
		
		if typeof(target) != TYPE_STRING:
			map_type = Globals.current_map.map_type
			var map_variation = Globals.current_map.variation
			if map_variation != null:
				map_type = map_type + "/" + map_variation
			
		var map_data = Globals.maps[map_type]
		var target_areamap
		
		if typeof(target) == TYPE_STRING:
			target_areamap = map_data
			
			# Static maps created with .instance() are GCed on exit. Recreate.
			# This makes a massive assumption that they're stateless ...
			
			# TODO: this code doesn't really belong here, does it? Should probably have
			# a dictionary of static maps to some func that creates them or something.
			if target == "Final":
				target_areamap = EndGameMap.instance()
			elif target == "Home":
				target_areamap = HomeMap.instance()
			
			if typeof(map_data) == TYPE_ARRAY:
				for map in map_data:
					if map.area_type == AreaType.ENTRANCE:
						target_areamap = map
						break
		else:
			# probably an array of submap(s). Or if loading, could be the overworld.
			if typeof(map_data) == TYPE_ARRAY:
				for map in map_data:
					if map.grid_x == target.grid_x and map.grid_y == target.grid_y:
						target_areamap = map
						break
			else:
				target_areamap = map_data
		
		var show_map_name = false
		
		# Globals.current_map is ull on new game
		if Globals.current_map == null:
			show_map_name = true
		elif ReferenceChecker.is_previously_freed(Globals.current_map):
			show_map_name = true
		# change map type, not change to submap of the same type
		# Weird random crash bug: Invalid get index 'map_type' (on base: 'Node2D').
		# Can't fix it (tried so many ways), hence the "map_type in Globals.current_map"
		elif Globals.current_map != null and "map_type" in Globals.current_map and Globals.current_map.map_type != target_areamap.map_type:
			show_map_name = true
			
		var populated_map = PopulatedMapScene.instance()
		populated_map.initialize(target_areamap)

		var state = SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
		if not Globals.is_testing:
			yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
			if state.is_valid(true):
				state.resume()

		# pre_battle_position null check: non-null when player is previously freed
		# For the latter two conditions: adding area selection map broke here because
		# instance is disposed or StaticBody2D
		# https://trello.com/c/YSlZGwjL/8-area-selection-world-map
		if Globals.player != null and not ReferenceChecker.is_previously_freed(Globals.player) \
		and Globals.player is PlayerClass and Globals.pre_battle_position == null:#\
		#'freeze' in Globals.player and Globals.pre_battle_position == null:
			Globals.player.freeze()
		
		if Globals.is_testing == false:
			change_scene_to(tree, populated_map)
		
		Globals.current_map_scene = populated_map
		
		if auto_save:
			populated_map.schedule_autosave()
		
		if show_map_name:
			var map_name_label = MapNameLabel.instance()
			map_name_label.show_map_name(target_areamap)
			
			# Center, 100px from top
			var container = CenterContainer.new()
			container.name = "Fade Container"
			container.set_anchors_and_margins_preset(Control.PRESET_CENTER_TOP)
			container.margin_top += 100
			# Offset is, just, wrong. Not sure why. Kludgey fix. Experimentally-derived value
			container.margin_left -= 118
			container.add_child(map_name_label)
			
			# Add to scene
			# The usual root.get_child(root.get_child_count() - 1) doesn't work here.
			# That's because, in addition to the Node2Ds, we have CanvasModulate + Tween.
			# So, get the last child who's not one of those.
			
			var root = tree.get_root()
			var current_scene = get_current_scene(root)
			
			var ui = current_scene.get_node("UI")
			if Globals.is_testing == false:
				ui.add_child(container) # null during tests
			
			# Wait 3s, then fade over 1s
			var tween_helper = TweenHelper.new().fade_out(current_scene, container, 1)
			var timer = Timer.new()
			timer.wait_time = 5.0
			timer.connect("timeout", tween_helper, "start")
			timer.start()
			current_scene.add_child(timer)
			
# Returns the last child that's not a Tween or CanvasModulate.
static func get_current_scene(root):
	var child_count = root.get_child_count()
	var last_child = root.get_child(0)
	
	for i in range(child_count):
		var child = root.get_child(i)
		var clazz = child.get_class()
		if clazz != "CanvasModulate" and clazz != "Tween":
			last_child = child
	
	return last_child
			
# Make it the current scene. Necessary to keep the type.
# If we use change_scene, it becomes a Node2D, not an AreaMap.
static func change_scene_to(tree, scene_instance):
	if Globals.current_map_type != "Final" and Globals.current_map_type != "Home":
		_remove_monster_instances()
	
	var root = tree.get_root()
	var current_scene = get_current_scene(root)
	call_deferred("_free_current_scene", current_scene)
	
	current_scene = scene_instance
	
	# http://docs.godotengine.org/en/3.0/getting_started/step_by_step/singletons_autoload.html?highlight=change_scene	
	tree.get_root().add_child(current_scene)
	# Optional, to make it compatible with the SceneTree.change_scene() API.
	tree.set_current_scene(current_scene)

static func switch_to_battle_if_touched_player(tree, monster, body):
	if body == Globals.player and Globals.player.can_fight():
		
		# Keep a list of monsters to restore after battle
		Globals.previous_monsters = Globals.current_map_scene.get_monsters()
		# Keep track of who to remove if we won
		Globals.current_monster = monster.data_object
		
		if monster.data_object is Boss:
			Globals.battle_spoils = Globals.current_monster.key_item
		
		if "events" in monster and monster.events != null and len(monster.events) > 0:
			# Only used for bosses, but ya3ne, global code
			var event_manager = EventManagement.new(tree)
			# Sets up to show post-battle events if applicable
			event_manager.show_prebattle_events(monster)
			yield(event_manager, "events_done")
		
		if not monster is Boss:
			monster.freeze()
		
		start_battle(tree, monster.data_object["data"])
		

static func _show_battle_transition(tree, animation_time_seconds):
	var camera_tween = Tween.new()
	camera_tween.interpolate_property(Globals.player.get_node("Camera2D"), "zoom", Vector2(1, 1), Vector2(0, 0), animation_time_seconds, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	var root = tree.get_root()	
	root.add_child(camera_tween)
	
	camera_tween.start()
	
	SceneFadeManager.fade_out(tree, animation_time_seconds)
	
	return [camera_tween]
	
static func start_battle(tree, monster_data):
	# Transition
	Globals.player.freeze()
	
	AudioManager.new().play_sound("battle-transition")
	
	var animation_time_seconds = 0.5
	var root = tree.get_root()
	var to_remove = _show_battle_transition(tree, animation_time_seconds) # returns immediately
	yield(tree.create_timer(animation_time_seconds), 'timeout')
	for item in to_remove:
		root.remove_child(item)
		
	# Start battle
			
	Globals.won_battle = false
	# We mutate data eg. health. So if you fight the same monster, win/lose, then the
	# second time, health/etc. will be reduced. We don't want that. So clone data here.
	var data = monster_data.duplicate()
	
	# Restore position after battle
	Globals.pre_battle_position = [Globals.player.position.x, Globals.player.position.y]
	Globals.current_monster_type = data.type
	var battle_scene = StreamlinedRecallBattleScene.instance()
	battle_scene.set_monster_data(data)
	change_scene_to(tree, battle_scene)

static func _free_current_scene(scene):
	scene.queue_free()

static func _remove_monster_instances():
	# Don't crash if we have a static map and `monsters` is not defined.
	# This is reflection magic: if the field exists, set it to empty-dictionary.
	if Globals.current_map_type != "Final" and Globals.current_map_type != "Home" and Globals.current_map != null and 'monsters' in Globals.current_map:
		# GCed. Don't leave deleted objects around. If you do, the next
		# time you save (iterate all maps/submaps and save objects), you
		# run into [deleted, deleted, ...] which crashes.
		Globals.current_map.monsters = {}
