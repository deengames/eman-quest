extends Node2D

const PlayerData = preload("res://Entities/PlayerData.gd")

const TILE_WIDTH = 64
const TILE_HEIGHT = 64
const SUBMAP_WIDTH_IN_TILES = 60
const SUBMAP_HEIGHT_IN_TILES = 51
const WORLD_WIDTH_IN_TILES = 30 # 1920/64
const WORLD_HEIGHT_IN_TILES = 17 # 1080/64

signal clicked_on_map(position)

var player # current player instance. Used for collision detection mostly.

####
# Start: persist to save game. Set in world generator.
var maps = {} # eg. "forest" => forest (AreaMap/data class) instance
var player_data = PlayerData.new() # the actual player data.
var story_data = {} # set in GenerateWorldScene; boss type, village name, etc.
# Vector2. come back to these coordinates after leaving the current dungeon. 
var overworld_position
var current_map # AreaMap instance
var transition_used # MapDestination instance
var sequence_trigger_difficulty = 4 # Number of tiles to show in sequence, eg. 4
# End: persist
####

# Used for positioning when changing maps. Probably does not need to be persisted
# because the value is only set very momentarily when the player steps on a
# transition to change rooms/maps.

var current_map_scene # PopulatedMapScene instance

### State to persist on area map after battles
# TODO: move into a separate autoload?
var pre_battle_position = [0, 0]
var won_battle = false
var battle_spoils = null # KeyItem
# Coordinates of monsters on-map before battle
var previous_monsters = null # type => pixel positions
var current_monster = null # monster.data_object
var current_monster_type = ""

func _ready():
	randomize()
	# abc gives frost forest
	# abcdef gives forest
	#seed("abcdef".hash())
	
# Returns integer value from min to max inclusive
# Source: https://godotengine.org/qa/2539/how-would-i-go-about-picking-a-random-number
func randint(minimum, maximum):
	return range(minimum, maximum + 1)[randi() % range(minimum, maximum + 1).size()]