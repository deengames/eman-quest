extends Node

var _feature_map = {
	### Stuff that's going into production
	# User-facing
	# Non-user facing
	"defend action": true, # Exists in old and new battle engine
	"tech_points": true, # points and skills
	
	### Old/defunct ones, mostly old battle engine toggles
	"streamlined battles: enemy triggers": false,
	"consecutive picks battle bonus": true,
	"actions require energy": false,
	"equipment generates tiles": true,
	"sequence battle triggers": true,
	"n-back battle triggers": false,
	"unlimited battle choices": false,
	"instant actions": true,
	"zoom-out maps": false, # no longer toggleable via options menu
}

func set_state(feature, enabled):
	if feature in self._feature_map:
		_feature_map[feature] = enabled
	else:
		print("Trying to set feature " + feature + " which doesn't exist!")
		
func is_enabled(feature_name):
	return feature_name in self._feature_map.keys() and self._feature_map[feature_name] == true