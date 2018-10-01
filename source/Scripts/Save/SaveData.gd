extends Node

### These are all defined in Globals.gd
var maps # dictionary of name => AreaMap
var story_data # dictionary of key/value pairs like final villain type
var player_data # PlayerData instance

func _init(player_data, maps, story_data):
	self.player_data = player_data
	self.maps = maps
	self.story_data = story_data