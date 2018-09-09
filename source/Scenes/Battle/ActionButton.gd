extends Area2D

const GridTile = preload("res://Scenes/Battle/GridTile.gd")
signal action_selected
var action = ""

func initialize(action):
	self.action = action
	if action in GridTile.Actions.keys():
		$Sprite.region_rect.position.x = GridTile.Actions[action]
	else:
		$Sprite.region_rect.position.x = GridTile.AdvancedActions[action]

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		self.emit_signal("action_selected", self)
