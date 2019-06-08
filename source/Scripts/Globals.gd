extends Node2D

signal clicked_on_map(position)
signal battle_over

const PlayerData = preload("res://Entities/PlayerData.gd")
const ReferenceChecker = preload("res://Scripts/ReferenceChecker.gd")

const TILE_WIDTH = 64
const TILE_HEIGHT = 64
# 1920x1080 / 64x64 => 30/17
const SUBMAP_WIDTH_IN_TILES = 60
const SUBMAP_HEIGHT_IN_TILES = 40
const WORLD_WIDTH_IN_TILES = 30 # 1920/64
const WORLD_HEIGHT_IN_TILES = 18 # 1080/64

const WALKABLE_TILES = ['Grass', 'Dirt', 'Ground']
const SCENE_TRANSITION_TIME_SECONDS = 0.5

var player # current player instance. Used for collision detection mostly.

####
# Start: persist to save game. Set in world generator.
var maps = {} # eg. "forest/frost" => forest (AreaMap/data class) instance
var player_data = PlayerData.new() # the actual player data.
var story_data = {} # set in GenerateWorldScene; boss type, village name, etc.
# Vector2. come back to these coordinates after leaving the current dungeon. 
var overworld_position
var current_map # AreaMap instance
var world_areas # Array of areas, in order. eg. ["Forest/Death", "Cave/Lava", "Forest/Frost"]
var quest # Quest instance
var seed_value
# No easy way to say "quest boss defeated" vs. non-quest boss defeated.
# Non-quest bosses don't exist. And we gave items away in the last battle.
# Anyway, this increments whenever you kill a boss. Used for final dungeon,
# and to figure out if we should show the current boss (eg. show boss #3 only
# after we kill boss #1-2).
var bosses_defeated = 0
var showed_final_events = false
var beat_last_boss = false
var show_battle_tutorial = true
var show_first_map_tutorial = false
# End: persist
####

# Used for positioning when changing maps. Probably does not need to be persisted
# because the value is only set very momentarily when the player steps on a
# transition to change rooms/maps.

var current_map_scene # PopulatedMapScene instance
var current_map_type = ""
var transition_used # MapDestination instance

### State to persist on area map after battles
# TODO: move into a separate autoload?
var pre_battle_position = null
var won_battle = false
var battle_spoils = null # KeyItem
# Coordinates of monsters on-map before battle
var previous_monsters = null # type => pixel positions
var current_monster = null # monster.data_object. Clears after battle.
var current_monster_type = "" # DOES/SHOULD NOT clear after battle, used for post-fight quest events!

##### region: terrible hacks. You should be ashamed. :/
# TERRIBLE HACK. Used only to place player properly after we load game.
# Because of fading, the player instance is not created yet; we have to fade
# out before we show the current map, and creating that map creates the player.
# So, we can't set the player coordinates; we need to set that later.
var future_player_position = null # Vector2
var post_fade_position = null # Vector2
# Hack. See: https://www.pivotaltracker.com/story/show/163181477
var unfreeze_player_in_process = false
var is_dialog_open = false # "Static" variable
###### end terrible hacks

# TODO: can make this a string (event name) to emit if required
var emit_battle_over_after_fade = false # trigger Global.battle_over after next fade finishes

#### ONLY FOR TESTING, ya3ne, making stuff more testable. Like, disable assertions
# about deeply-nested things and their invariants, so we don't have to mock too much.
var is_testing = false

func _ready():
	pass
	
# https://docs.godotengine.org/en/3.0/tutorials/inputs/inputevent.html#how-does-it-work
# Fires if nothing else handled the event, it seems.
func _unhandled_input(event):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		var position = get_global_mouse_position()
		# Clicks seem ... off for some reason. Not sure why. Adjust manually.
		position.x -= Globals.TILE_WIDTH / 2
		position.y -= Globals.TILE_HEIGHT
		Globals.emit_signal("clicked_on_map", position)
	
# Returns integer value from min to max inclusive
# Source: https://godotengine.org/qa/2539/how-would-i-go-about-picking-a-random-number
func randint(minimum, maximum):
	return range(minimum, maximum + 1)[randi() % range(minimum, maximum + 1).size()]
	
func hide_ui():
	# Rarely, this is something unusual, like AlphaFluctuator instance; hence, is/in check
	# https://www.pivotaltracker.com/story/show/164255140
	# Regression: broke this by adding "hide_ui in current_map_scene", which I fixed again in https://www.pivotaltracker.com/story/show/164947430
	if self.current_map_scene != null and not ReferenceChecker.is_previously_freed(self.current_map_scene):
		self.current_map_scene.hide_ui()

func show_ui():
	# Rarely, this is something unusual, like AlphaFluctuator instance
	if self.current_map_scene != null and not ReferenceChecker.is_previously_freed(self.current_map_scene):
		self.current_map_scene.show_ui()