extends "StaticMap.gd"

const map_type = 'Home'

var _showing_intro_events = false

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	$Mama.visible = Globals.beat_last_boss
	if Globals.beat_last_boss:
		self.remove_child($Intro)

func show_intro_events():
	$Intro.visible = true
	self._showing_intro_events = true
	
	$Mama.visible = true
	$Mama.appear_wounded()
	$Mama.position.y += Globals.TILE_HEIGHT
	
	# Called by GenerateWorldScene
	var player = Globals.player
	player.position = $Locations/Start.position
	player.freeze()
	
	$Intro/StoryWindow.show_texts([
		["Mama", "AIEEEEEEEEEEEEEEEEEEEEEE!!!!"],
		["Baba", "Unhand her, you brute!"],
		["Bandit", "Hehehehe! Shut it, old man!"],
		["Bandit", "The boss wanted her, and I got her!"],
	])
	
	$Intro/StoryWindow.connect("shown_all", self, "_conclude_intro_events")
	
func _conclude_intro_events():
	
	yield(get_tree().create_timer(1), 'timeout')
	# Play sound here
	
	var mama = $Mama
	var bandit = self.get_node("Intro/Bandit-Intro")
	bandit.run("Down", 4) # run off-screen
	mama.visible = false
	
	bandit.connect("reached_destination",  Globals.player, "unfreeze")