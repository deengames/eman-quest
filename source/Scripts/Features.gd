extends Node

var _feature_map = {
	"consecutive picks battle bonus": true,
	"actions require energy": false,
	"defend action": false,
	"equipment generates tiles": true,
	"sequence battle triggers": true,
	"n-back battle triggers": false,
	"unlimited battle choices": false,
	"zoom-out maps": false,
	"instant actions": true,
	"streamlined battles: enemy triggers": false
}

func set(feature, enabled):
	if feature in self._feature_map:
		_feature_map[feature] = enabled
	else:
		print("Trying to set feature " + feature + " which doesn't exist!")
		
func is_enabled(feature_name):
	return feature_name in self._feature_map.keys() and self._feature_map[feature_name] == true