extends Node

# TODO: back to const when done testing battle variations
var FEATURE_MAP = {
	"consecutive picks battle bonus": true,
	"actions require energy": true,
	"defend action": false,
	"equipment generates tiles": true,
	"sequence battle triggers": true
}

func is_enabled(feature_name):
	return feature_name in FEATURE_MAP.keys() and FEATURE_MAP[feature_name] == true