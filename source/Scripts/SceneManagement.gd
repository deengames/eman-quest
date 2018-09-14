extends Node

const PopulatedMapScene = preload("res://Scenes/PopulatedMapScene.tscn")

static func change_map_to(tree, map_type):
	# Create map instance
	var map_data = Globals.maps[map_type]
	var populated_map = PopulatedMapScene.instance()
	populated_map.initialize(map_data)
	
	change_scene_to(tree, populated_map)
	
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
	
static func _free_current_scene(scene):
	scene.free()