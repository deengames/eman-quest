extends Node2D

const AreaSymbols = preload("res://Scenes/Maps/AreaSymbols.tscn")
const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const ClickHereArrow = preload("res://Scenes/UI/ClickHereArrow.tscn")
const EndGameMap = preload("res://Scenes/Maps/EndGameMap.tscn")
const HomeMap = preload("res://Scenes/Maps/Home.tscn")
const MapDestination = preload("res://Entities/MapDestination.gd")
const Quest = preload("res://Entities/Quest.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")

const GLOBAL_FONT = preload("res://Theme/Default-24px.tres")

const _CENTER_X = 6
const _SECOND_ROW_Y = 5

var _transitioning = false

func _ready():
	# Fix a bug where: final battle => win => leave => come back spawns you in front
	# of the final boss location. This is because (somehow) we never reset
	# Globals.pre_battle_position. This is easy to do, so do it here, in AreaSelect.
	Globals.pre_battle_position = null
	
	var template = AreaSymbols.instance()
	var children = template.get_children()
	
	# Duplicate cause otherwise, error: can't add when parent is already something else
	var home = _get_by_name(children, "Home").duplicate()
	home.name = "Home"
	add_child(home)
	_add_label(home, "Home")
	
	var next = 1
	
	for area in Globals.world_areas:
		var divider = area.find("/")
		var type = area.substr(0, divider)
		var variation = area.substr(divider + 1, len(area))
		var node_name = variation + " " + type
		
		var node = _get_by_name(children, node_name.replace(" ", "")).duplicate()
		node.name = type + "-" + variation # can't use "/" so use "-" instead, needed on click
		_move_to_position(node, next)
		add_child(node)
		_add_label(node, node_name)
		
		if next == 1 and Globals.show_first_map_tutorial:
			Globals.show_first_map_tutorial = false
			var tutorial = ClickHereArrow.instance()
			add_child(tutorial)
			tutorial.position = node.position
			tutorial.position.x += Globals.TILE_WIDTH * 1.5
			tutorial.position.y += Globals.TILE_HEIGHT * 2
			tutorial.rotation_degrees = 180
		
		next += 1
	
	var end_game = _get_by_name(children, "EndGame").duplicate()
	end_game.name = "EndGame"
	_move_to_position(end_game, 4)
	_add_label(end_game, Globals.FINAL_MAP_NAME)
	add_child(end_game)
	
	# Fixes a crash after completing the final battle
	# https://trello.com/c/4zj0dLpy/95-post-final-battle-crashes
	Globals.transition_used = null
	
	# Fix a myriad of bugs about transitioning maps takes you to the wrong position
	# https://trello.com/c/Fen3iL5q/93-end-game-transitions-are-messed-up
	Globals.pre_battle_position = null

func _get_by_name(array, target):
	for item in array:
		if item.get_name() == target:
			return item
	
	return null

func _move_to_position(tiles, n):
	# n = 0, 1, 2, 3, or 4 (end-game)
	if n < 4:
		tiles.position.x = Globals.TILE_WIDTH * (n * 4) # 3 tiles, 1 space
	else:
		# end-game map
		tiles.position.x = Globals.TILE_WIDTH * _CENTER_X
		tiles.position.y = Globals.TILE_HEIGHT * _SECOND_ROW_Y

func _add_label(node, caption):
	var label = Label.new()
	label.text = caption
	label.add_font_override("font", GLOBAL_FONT)
	label.margin_left = node.position.x
	label.margin_right = label.margin_left + (3 * Globals.TILE_HEIGHT)
	label.align = Label.ALIGN_CENTER
	label.margin_top = node.position.y + (3 * Globals.TILE_HEIGHT)
	add_child(label)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if not _transitioning and (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		var clicked_on = _get_clicked_on(event.position)
		if clicked_on != null:
			_transitioning = true
			_teleport_to(clicked_on)

func _get_clicked_on(position):
	for child in self.get_children():
		if child is TileMap:
			if position.x >= child.position.x and position.y >= child.position.y and \
			position.x <= child.position.x + (3 * Globals.TILE_WIDTH) and \
			position.y <= child.position.y + (3 * Globals.TILE_HEIGHT):
				return child.get_name()
				
	return null

# Area: SlimeForest, Home, etc.
func _teleport_to(destination):
	var tree = get_tree()
	
	if destination == "Home" or destination == "EndGame":
		# 100% copy/paste from MapWarp.gd
		var static_map
		if destination == "Home":
			static_map = HomeMap.instance()
		else:
			static_map = EndGameMap.instance()
		
		SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
		yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
		SceneManagement.change_scene_to(tree, static_map)
	else:
		# Find the transition from the overworld. Needed to position.
		destination = destination.replace("-", "/")
		
		var maps = Globals.maps[destination]
		for submap in maps:
			if submap.area_type == AreaType.AREA_TYPE.ENTRANCE:
				for transition in submap.transitions:
					if transition.target_map == "Overworld":
						# Swap coordinates. This is a transition BACK to overworld.
						# Make it a transition INTO this position. Swap my/target positions.
						# As for the -1; PopulatedMapScene adds +1 to y to fix stuff.
						var copy = MapDestination.new(null, null, Vector2(transition.my_position.x, transition.my_position.y - 1), null)
						Globals.transition_used = copy
						SceneManagement.change_map_to(tree, destination)
						return