extends Node

var item_name = ""
var description = ""

func initialize(item_name, description):
	self.item_name = item_name
	self.description = description

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
