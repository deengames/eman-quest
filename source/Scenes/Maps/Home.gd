extends "StaticMap.gd"

const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")

const map_type = 'Home'

var _showing_intro_events = false

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	$Mama.visible = Globals.beat_last_boss
	if Globals.beat_last_boss:
		self.remove_child($Intro)

func show_intro_events():
	$"Bandit-Intro".visible = true
	self._showing_intro_events = true
	
	$Mama.visible = true
	$Mama.appear_wounded()
	$Mama.position.y += Globals.TILE_HEIGHT
	
	# Called by GenerateWorldScene
	var player = Globals.player
	player.position = $Locations/Start.position
	player.freeze()
	
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	var dialog_window = DialogueWindow.instance()
	current_scene.add_child(dialog_window)
	
	var viewport = get_viewport_rect().size
	dialog_window.position = viewport / 4
		
	dialog_window.show_texts([
		["Mama", "AIEEEEEEEEEEEEEEEEEEEEEE!!!!"],
		["Baba", "Unhand her, you brute!"],
		["Bandit", "Hehehehe! Shut it, old man!"],
		["Bandit", "The boss wanted her, and I got her!"],
	])
	
	dialog_window.connect("shown_all", self, "_conclude_intro_events")
	
func _conclude_intro_events():
	
	yield(get_tree().create_timer(1), 'timeout')
	# Play sound here
	
	var bandit = $"Bandit-Intro"
	bandit.run("Down", 4) # run off-screen
	self.remove_child($Mama)
	
	bandit.connect("reached_destination",  Globals.player, "unfreeze")