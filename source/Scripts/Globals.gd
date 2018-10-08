extends Node2D

const PlayerData = preload("res://Entities/PlayerData.gd")

const TILE_WIDTH = 64
const TILE_HEIGHT = 64
const WORLD_WIDTH_IN_TILES = 30 # 1920/64
const WORLD_HEIGHT_IN_TILES = 17 # 1080/64

var player # current player instance. Used for collision detection mostly.

####
# Start: persist to save game. Set in world generator.
var maps = {} # eg. "forest" => forest (AreaMap/data class) instance
var player_data = PlayerData.new() # the actual player data.
var story_data = {} # set in GenerateWorldScene; boss type, village name, etc.

# Vector2. come back to these coordinates after leaving the current dungeon. 
var overworld_position
# Used for positioning when changing maps
var transition_used

# End: persist
####

var current_map # AreaMap instance
var current_map_scene # PopulatedMapScene instance

### State to persist on area map after battles
# TODO: move into a separate autoload?
var pre_battle_position = [0, 0]
var won_battle = false
var battle_spoils = null # KeyItem
# Coordinates of monsters on-map before battle
var previous_monsters = {} # type => pixel positions
var current_monster = null # monster.data_object
var current_monster_type = ""

func _ready():
	randomize()
	seed("abc".hash())
	
# Returns integer value from min to max inclusive
# Source: https://godotengine.org/qa/2539/how-would-i-go-about-picking-a-random-number
func randint(minimum, maximum):
	return range(minimum, maximum + 1)[randi() % range(minimum, maximum + 1).size()]