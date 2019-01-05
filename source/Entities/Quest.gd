extends Node2D

# Number and order of bosses. Eg. [null, {...}, null] means we have to replace
# the second boss with the data from this array. [{...}] means replace only first boss.
const BOSSES = [
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

# Number and order of boss events. Null means ignored/nothing.
# This is a limited-context grammar. For current story, we just support a few events:
# 1) messages (show message boxes with text)
# 2) run away (flee from player until off-screen)
const BOSS_EVENTS = [
	{
		"pre-fight": [
			{ "messages": [
				["Bandit", "Rats! How did you find me so fast?"],
				["Mama", "I knew you would find us!"],
				["Bandit", "No matter! Your days are over, punk!"]
			] }
		],
		"post-fight": [
			{ "messages": [
				["Bandit", "Ugh! You're stronger than you look, runt!"],
				["Bandit", "Forget this! I'm outta here!"]
			] },
			{ "run away": "Bandit" },
			{ "messages": [
				["Hero", "Are you okay? Did they hurt you?"],
				["Mama", "I'm fine. Don't worry about me, you have to stop them!"],
				["Mama", "I heard them saying they're summoning a monster from {map2} ..."],
				["Mama", "Go stop them! I'll be okay to get home by myself."],
				["Hero", "Okay. InshaAllah (God willing), we will catch them."]
			] },
			{ "run away": "Mama" }
		]
	}
]

func to_dict():
	return {
		"bosses": self.bosses
	}

static func from_dict(dict):
	var to_return = new()
	to_return.bosses = dict["bosses"]
	return to_return