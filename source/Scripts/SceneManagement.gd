extends Node

const MemoryTileBattleScene = preload("res://Scenes/Battle/MemoryTileBattleScene.tscn")
const PopulatedMapScene = preload("res://Scenes/PopulatedMapScene.tscn")

static func change_map_to(tree, map_type):
	# Create map instance
	var map_data = Globals.maps[map_type]
	var populated_map = PopulatedMapScene.instance()
	populated_map.initialize(map_data)
	
	change_scene_to(tree, populated_map)
	
	if map_type == "Overworld":
		var camera = Globals.player.get_node("Camera2D")
		# zoom of 2 = 50%
		# TODO: tween
		camera.zoom.x = 2
		camera.zoom.y = 2
	
# Make it the current scene. Necessary to keep the type.
# If we use change_scene, it becomes a Node2D, not an AreaMap.
static func change_scene_to(tree, scene_instance):
	# http://docs.godotengine.org/en/3.0/getting_started/step_by_step/singletons_autoload.html?highlight=change_scene
	var root = tree.get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	call_deferred("_free_current_scene", current_scene)
	
	current_scene = scene_instance
	tree.get_root().add_child(current_scene)
	# Optional, to make it compatible with the SceneTree.change_scene() API.
	tree.set_current_scene(current_scene)

static func switch_to_battle_if_touched_player(monster, body):
	if body == Globals.player and Globals.player.can_fight():
		
		# Reset state of last battle's results
		Globals.pre_battle_position = [Globals.player.position.x, Globals.player.position.y]
		Globals.won_battle = false
		
		# Keep a list of monsters to restore after battle
		Globals.previous_monsters = Globals.current_map_scene.get_monsters()
		# Keep track of who to remove if we won
		Globals.current_monster_type = monster.data["type"]
		Globals.current_monster = monster.data_object
		
		var battle_scene = MemoryTileBattleScene.instance()
		battle_scene.set_monster_data(monster.data.duplicate())
		change_scene_to(monster.get_tree(), battle_scene)

static func _free_current_scene(scene):
	scene.free()