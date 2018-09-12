extends Node

const FEATURE_MAP = {
	"consecutive_picks_battle_bonus": true,
	"actions_require_energy": true
}

func is_enabled(feature_name):
	return feature_name in FEATURE_MAP.keys() and FEATURE_MAP[feature_name] == true