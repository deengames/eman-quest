extends Node2D

# Number and order of bosses. Eg. [null, {...}, null] means we have to replace
# the second boss with the data from this array. [{...}] means replace only first boss.
var bosses = [
	{
		"type": "Bandit",
		"health": 300,
		"strength": 30,
		"defense": 12,
		"turns": 2,
		"experience points": 200,
		
		"skill_probability": 40,
		"skills": {
			"roar": 60,
			"poison": 30
		},
		"skill_messages": {
			"poison": "stabs you with a poisoned dagger!"
		},
		"drops": {
			"name": "Bandit Bandanna",
			"description": "A small red square of cloth decorated  with white circles"
		}
	},
]

func to_dict():
	return {
		"bosses": self.bosses
	}

static func from_dict(dict):
	var to_return = new()
	to_return.bosses = dict["bosses"]
	return to_return