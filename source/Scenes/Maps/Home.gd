extends "StaticMap.gd"

const Bandit = preload("res://Entities/MapEntities/Bandit/Bandit.tscn")
const DialogueWindow = preload("res://Scenes/UI/DialogueWindow.tscn")
const Mama = preload("res://Entities/MapEntities/Mom.tscn")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

const map_type = 'Home'

var _showing_intro_events = false
# used in intro only
var _mama
var _bandit

func _ready():
	var player = Globals.player
	
	# https://www.pivotaltracker.com/story/show/164848304
	# Somehow, setting player position doesn't apply unless we change it here.
	# It looks like a Godot bug. Ya know what I'm talkin' about. Traced all the places
	# where we change the player's position, and none of them are incorrect. Somehow,
	# even when frozen, she just ends up going to the location specified here. ?????
	if Globals.pre_battle_position != null:
		player.position = Vector2(Globals.pre_battle_position[0], Globals.pre_battle_position[1])
	else:
		player.position = $Locations/Entrance.position
	
	if Globals.bosses_defeated == 2:
		self.remove_child($Dad)
	
	if Globals.bosses_defeated >= 1:
		var mama = _spawn(Mama, $Locations/Mama)
		Globals.player.z_index = 9

func show_intro_events():
	self._showing_intro_events = true
	
	_mama = _spawn(Mama, $Locations/Mama)
	_mama.position.y += Globals.TILE_HEIGHT
	_mama.appear_wounded()
	
	_bandit = _spawn(Bandit, $Locations/Bandit)
	
	# Called by GenerateWorldScene
	var player = Globals.player
	player.position = $Locations/Start.position
	player.freeze()
	
	var root = get_tree().get_root()
	var current_scene = SceneManagement.get_current_scene(root)
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
	
	_bandit.run("Down", 4) # run off-screen
	self.remove_child(_mama)
	_bandit.connect("reached_destination",  self, "_bandit_reached")
	
func _bandit_reached():
	Globals.player.unfreeze()
	
func _spawn(clazz, location):
	var instance = clazz.instance()
	self.add_child(instance)
	instance.position = location.position
	return instance