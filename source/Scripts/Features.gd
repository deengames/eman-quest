extends Node

const FEATURE_MAP = {
	"battle_three_in_a_row_bonus": true
}

func is_enabled(feature_name):
	return feature_name in FEATURE_MAP.keys() and FEATURE_MAP[feature_name] == true