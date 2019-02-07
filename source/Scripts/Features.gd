extends Node

var _feature_map = {
	"streamlined battles: enemy triggers": false,
	
	"defend action": true, # Old and new battle engine
	"zoom-out maps": false,
	
	# Current prototype. May keep these.
	"tech_points": true, # points and skills
	
	# Old/defunct battle engine
	"consecutive picks battle bonus": true,
	"actions require energy": false,
	"equipment generates tiles": true,
	"sequence battle triggers": true,
	"n-back battle triggers": false,
	"unlimited battle choices": false,
	"instant actions": true
}

func set(feature, enabled):
	if feature in self._feature_map:
		_feature_map[feature] = enabled
	else:
		print("Trying to set feature " + feature + " which doesn't exist!")
		
func is_enabled(feature_name):
	return feature_name in self._feature_map.keys() and self._feature_map[feature_name] == true