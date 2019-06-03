extends Node2D

const AreaSymbols = preload("res://Scenes/Maps/AreaSymbols.tscn")
const Quest = preload("res://Entities/Quest.gd")

const GLOBAL_FONT = preload("res://Theme/Default-24px.tres")

const _CENTER_X = 6
const _SECOND_ROW_Y = 5

func _ready():
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
		node.name = node_name
		_move_to_position(node, next)
		add_child(node)
		_add_label(node, node_name)
		next += 1
	
	if true:#Globals.bosses_defeated == 3:
		var end_game = _get_by_name(children, "EndGame").duplicate()
		end_game.name = "EndGame"
		_move_to_position(end_game, 4)
		_add_label(end_game, Quest.FINAL_MAP_NAME)
		add_child(end_game)

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
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		var clicked_on = _get_clicked_on(event.position)
		if clicked_on != null:
			print("Clicked on " + clicked_on)

func _get_clicked_on(position):
	for child in self.get_children():
		if child is TileMap:
			if position.x >= child.position.x and position.y >= child.position.y and \
			position.x <= child.position.x + (3 * Globals.TILE_WIDTH) and \
			position.y <= child.position.y + (3 * Globals.TILE_HEIGHT):
				return child.get_name()
				
	return null