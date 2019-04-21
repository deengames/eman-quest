extends Node2D

const EndGameMap = preload("res://Scenes/Maps/EndGameMap.tscn")
const HomeMap = preload("res://Scenes/Maps/Home.tscn")
const MapDestination = preload("res://Entities/MapDestination.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

######## TODO: use tileset tiles instead?
const EntranceImageXPositions = {
	"Dungeon": 320,
	"Cave": 64,
	"Forest": 128,
	"Final": 320,
	"Home": 0
}

const EntranceImageYPositions = {
	"Dungeon": 0,
	"Home": 64
}

export var destination = "" # dungeon, cave, forest, final
export var appear_beside = "" # Dungeon, cave, forest, etc. entrance

var _initialized = false
var map_destination # MapDestination instance

func _ready():
	# Placed statically on some hand-crafted map, probably. If not, _initialized = true.
	if not self._initialized:
		if destination in EntranceImageXPositions.keys():
			$Sprite.region_rect.position.x = EntranceImageXPositions[destination]
			if destination in EntranceImageYPositions.keys():
				$Sprite.region_rect.position.y = EntranceImageYPositions[destination]
			$Sprite.visible = true
		else:
			$Sprite.visible = false
			
		self._initialized = true
	
	self._set_map_destination()

func initialize_from(map_destination):
	self.map_destination = map_destination
	$Sprite.visible = false

	var target_map = map_destination.target_map
	if typeof(target_map) == TYPE_STRING:
		var divider = target_map.find('/')
		if divider > -1:
			# forest/slime => forest
			target_map = target_map.substr(0, divider)
		
	if target_map in EntranceImageXPositions.keys():
		$Sprite.region_rect.position.x = EntranceImageXPositions[target_map]
		if target_map in EntranceImageYPositions.keys():
			$Sprite.region_rect.position.y = EntranceImageYPositions[target_map]
		$Sprite.visible = true
	else:
		# Transition from map => world or map => map eg. in-forest maps
		$Sprite.visible = false
	self._initialized = true

###
# Assumes your desination is the overworld; find the relevant entrance (look
# at the map transitions to find them) and then set up a map_destination next to it.
###
func _set_map_destination():
	if self.destination == "Overworld":
		var overworld = Globals.maps["Overworld"]
		
		var transitions = overworld.transitions
		var target_position = null
		for transition in transitions:
			if transition.target_map.find(self.appear_beside) > -1:
				target_position = transition.my_position # position of this transition on the overworld
				# Destination IS NULL RARRGHHHH. If it wasn't, use it to determine position correctly.
				target_position.y += 1
		
		# TODO: can expose destination (last argument) so consumers can specify it; null for now
		# First argument, my_position, is irrelevant; so, null.
		self.map_destination = MapDestination.new(null, self.destination, target_position, null)
		
		if Globals.enable_assertions == true:
			assert (target_position != null)
		
func _on_Area2D_body_entered(body):
	if body == Globals.player:
		
		# If we had a post-fade position, player exited quickly from home to world map,
		# we don't want to restore to that position now.
		Globals.post_fade_position = null
		
		Globals.player.freeze()
		
		var tree = body.get_tree()
		var target_map = self.map_destination.target_map

		# Leaving overworld? Come back one tile under the current tile.
		if Globals.current_map.map_type == "Overworld":
			Globals.overworld_position = Vector2(self.position.x, self.position.y + Globals.TILE_HEIGHT)
			Globals.transition_used = null

		if typeof(target_map) == TYPE_STRING:
			# TODO: dry with SceneManagement TODO about this
			var static_map
			if target_map == "Final" or target_map == "Home":
				
				if target_map == "Final":
					static_map = EndGameMap.instance()
				elif target_map == "Home":
					static_map = HomeMap.instance()
				
				SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
				yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
				SceneManagement.change_scene_to(get_tree(), static_map)
				Globals.player.unfreeze()
			else:
				Globals.transition_used = self.map_destination
				SceneManagement.change_map_to(get_tree(), target_map)
		else:
			Globals.transition_used = self.map_destination
			SceneManagement.change_map_to(get_tree(), target_map)

		# Come back to the overworld? Restore coordinates.
		if typeof(self.map_destination.target_map) == TYPE_STRING and self.map_destination.target_map == "Overworld" and Globals.overworld_position != null:
			Globals.future_player_position = Globals.overworld_position
			Globals.overworld_position = null
			