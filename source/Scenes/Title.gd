extends Node2D

var BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
var MemoryTileBattleScene = preload("res://Scenes/Battle/MemoryTileBattleScene.tscn")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Battle/Monster.tscn")

func _ready():
	pass

func _on_newgame_Button_pressed():
	get_tree().change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_simplebattle_button_pressed():
	var battle_scene = MemoryTileBattleScene.instance()
	battle_scene.set_monster_data({
	"type": "Slime",
	"health": 30,
	"strength": 10,
	"defense": 4,
	"turns": 1,
	"experience points": 10,
	"skill_probability": 40, # 40 = 40%
	"skills": {
		# These should add up to 100
		"chomp": 100 # 20%,
	}
})
	
	SceneManagement.change_scene_to(get_tree(), battle_scene)


func _on_AdvancedBattleButton_pressed():
	var battle_scene = MemoryTileBattleScene.instance()
	
	battle_scene.set_monster_data({
		"type": "Volture",
		"health": 300,
		"strength": 50,
		"defense": 20,
		"turns": 3,
		"experience points": 100,
		"skill_probability": 60,
		"skills": {
			# These should add up to 100
			"chomp": 30,
			"vampire": 40,
			"shock": 30
		}
	});
	
	var battler = BattlePlayer.new()
	battler.max_health = 600
	battler.current_health = battler.max_health
	battler.strength = 50
	battler._defense = 30
	battler.num_pickable_tiles = 8
	battler.num_actions = 5
	battler.max_energy = 40
	battler.energy = battler.max_energy
	
	battle_scene.player = battler
	battle_scene.go_turbo()
	
	SceneManagement.change_scene_to(get_tree(), battle_scene)


func _on_LoadGameButton_pressed():
	var data = '{"armour":{"equipment_name":"Chumoo","filename":"res://Entities/Equipment.gd","grid_tiles":2,"primary_stat":2,"primary_stat_modifier":5,"secondary_stat":1,"secondary_stat_modifier":2,"tile_type":"attack","type":"armour"},"assigned_points":{"defense":0,"energy":0,"health":0,"num_actions":0,"num_pickable_tiles":0,"strength":0},"defense ":5,"equipment":[],"experience_points":0,"filename":"res://Entities/PlayerData.gd","health":60,"key_items":[],"level":1,"max_energy":20,"num_actions":3,"num_pickable_tiles":5,"strength":7,"unassigned_stats_points":0,"weapon":{"equipment_name":"Mabudi","filename":"res://Entities/Equipment.gd","grid_tiles":3,"primary_stat":1,"primary_stat_modifier":6,"secondary_stat":0,"secondary_stat_modifier":8,"tile_type":"attack","type":"weapon"}}'
	var current_line = parse_json(data)
	var filename = current_line["filename"]
	var new_object = load(filename).new()
	for i in current_line.keys():
		var value = current_line[i]
		print(i + " => " + str(typeof(value)))
		if typeof(value) == TYPE_DICTIONARY and value.has("filename"):
			var type = load(value["filename"])
			value = type.from_dict(value)
		
		new_object.set(i, value)
	pass
