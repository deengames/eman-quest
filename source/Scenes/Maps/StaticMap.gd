extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")
const Player = preload("res://Entities/Player.tscn")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")

### 
# A static map. Contains instructions to work + common code.
###

const map_type = "" # used in transitions, plays nice with code that looks up map_type.
var _audio_bgs = AudioManager.new()

func _ready():
	Globals.current_map = self
	Globals.current_map_type = self.map_type
	
	# Part of fixes for https://www.pivotaltracker.com/story/show/165001877
	Globals.current_map_scene = self
	Globals.player = Player.instance()
	self.add_child(Globals.player)
	
	SceneFadeManager.fade_in(self.get_tree(), Globals.SCENE_TRANSITION_TIME_SECONDS)

func get_tiles_wide():
	return $Ground.get_used_rect().size.x

func get_tiles_high():
	return $Ground.get_used_rect().size.y

# Part of fixes for https://www.pivotaltracker.com/story/show/165001877
# These don't need an implementation
func show_ui(): pass
func hide_ui(): pass

func _exit_tree():
	self._audio_bgs.clean_up_audio()