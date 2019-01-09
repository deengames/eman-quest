extends Node2D

const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const Boss = preload("res://Entities/Battle/Boss.gd")
const KeyItem = preload("res://Entities/KeyItem.gd")

const NPCS = {
	"Mom": preload("res://Entities/MapEntities/Mom.tscn")
}

# Number and order of bosses. Eg. [null, {...}, null] means we have to replace
# the second boss with the data from this array. [{...}] means replace only first boss.
# Can't be const because we have to set it when we load game.
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

# Again, not const because of saving. Each entry represents dungeon N, array to attach.
# "load" sucks with export, so preload up top and reference here.
var attach_quest_npcs = [
	["Mom"],
	["Bandit"],
	["FinalBoss", "Dad"]
]

# Number and order of boss events. Null means ignored/nothing.
# Note that, like the above, this is *per dungeon* not per boss.
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

static func add_quest_content_if_applicable(map, variation):
	var dungeon_type = map.map_type + "/" + variation
	var dungeon_number = Globals.world_areas.find(dungeon_type)
	var bosses = Globals.quest.bosses
	var npcs = Globals.quest.attach_quest_npcs
	
	# Add quest boss if there's one specified
	if map.area_type == AreaType.BOSS:
		# > -1 is redundant/guaranteed
		if dungeon_number > -1 and dungeon_number < len(bosses):
			var quest_boss = bosses[dungeon_number]
			# should be only one key/type/boss. Dictionary of type => data
			for key in map.bosses.keys():
				var item_data = quest_boss["drops"]
				var key_item  = KeyItem.new()
				key_item.initialize(item_data["name"], item_data["description"])
				
				# It's just one element. But it's an array, so ...
				# This seems weird. Replace all bosses with the quest boss?
				var replaced_bosses = []
				for old_boss in map.bosses[key]:
					var boss = Boss.new()
					# Replace at the old boss' coordinates
					boss.initialize(old_boss.x, old_boss.y, quest_boss, key_item)
					
					if dungeon_number < len(BOSS_EVENTS):
						var events = BOSS_EVENTS[dungeon_number]
						if events != null:
							boss.set_events(events)
					
					if dungeon_number < len(npcs):
						boss.attach_quest_npcs = npcs[dungeon_number]
					
					replaced_bosses.append(boss)
				
				map.bosses[key] = replaced_bosses

func to_dict():
	return {
		"bosses": self.bosses,
		"attach_quest_npcs": self.attach_quest_npcs
	}

static func from_dict(dict):
	var to_return = new()
	to_return.bosses = dict["bosses"]
	to_return.attach_quest_npcs = dict["attach_quest_npcs"]
	return to_return