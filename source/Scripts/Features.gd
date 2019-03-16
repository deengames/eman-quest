extends Node

var _feature_map = {
	# Stuff that's going into production	
	"defend action": true, # Exists in old and new battle engine
	"zoom-out maps": false, # toggleable via options menu
	"tech_points": true, # points and skills
	"monsters chase you": false,
	
	# Old/defunct ones, mostly old battle engine toggles
	"streamlined battles: enemy triggers": false,
	
	"consecutive picks battle bonus": true,
	"actions require energy": false,
	"equipment generates tiles": true,
	"sequence battle triggers": true,
	"n-back battle triggers": false,
	"unlimited battle choices": false,
	"instant actions": true
}

func set_state(feature, enabled):
	if feature in self._feature_map:
		_feature_map[feature] = enabled
	else:
		print("Trying to set feature " + feature + " which doesn't exist!")
		
func is_enabled(feature_name):
	return feature_name in self._feature_map.keys() and self._feature_map[feature_name] == true