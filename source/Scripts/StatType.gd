enum StatType {
	Health,
	Strength,
	Defense,
	Energy
}

static func to_string(stat_type):
	var names = StatType.keys()
	return names[stat_type]