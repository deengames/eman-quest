extends Node2D

const EndGameMap = preload("res://Scenes/Maps/EndGameMap.tscn")
const MapDestination = preload("res://Entities/MapDestination.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

const EntranceImageXPositions = {
	"Dungeon": 0,
	"Cave": 64,
	"Forest": 128,
	"Final": 320
}

var map_destination

func initialize_from(map_destination):
	self.map_destination = map_destination
	$Sprite.visible = true

	var target_map = map_destination.target_map
	if typeof(target_map) == TYPE_STRING and target_map in EntranceImageXPositions.keys():
		$Sprite.region_rect.position.x = EntranceImageXPositions[target_map]
	else:
		# Transition from map => world or map => map eg. in-forest maps
		$Sprite.visible = false

func _on_Area2D_body_entered(body):
	if body == Globals.player:
		var target_map = self.map_destination.target_map

		# Leaving overworld? Come back one tile under the current tile.
		if Globals.current_map.map_type == "Overworld":
			Globals.overworld_position = Vector2(self.position.x, self.position.y + Globals.TILE_HEIGHT)
			Globals.transition_used = null

		if typeof(target_map) == TYPE_STRING and target_map == "Final":
			# Final map is a special case. In many ways.
			var endgame_map = EndGameMap.instance()
			SceneManagement.change_scene_to(get_tree(), endgame_map)
		else:
			Globals.transition_used = self.map_destination
			SceneManagement.change_map_to(get_tree(), target_map)

		# Come back to the overworld? Restore coordinates.
		if Globals.current_map.map_type == "Overworld" and Globals.overworld_position != null:
			Globals.player.position = Globals.overworld_position
			Globals.overworld_position = null