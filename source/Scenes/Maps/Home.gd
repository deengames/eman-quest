extends "StaticMap.gd"

const map_type = 'Home'

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position

func show_intro_events():
	# Called by GenerateWorldScene
	var player = Globals.player
	player.position = $Locations/Start.position
	
	$Intro/StoryWindow.show_text("Mom", "AIEEEEEEEEEEEEEEEEEEEEEE!!!!")