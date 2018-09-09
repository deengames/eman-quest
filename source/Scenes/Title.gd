extends Node2D

var BattlePlayer = preload("res://Entities/BattlePlayer.gd")
var MemoryTileBattleScene = preload("res://Scenes/MemoryTileBattleScene.tscn")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Monsters/Slime.tscn")

func _ready():
	pass

func _on_newgame_Button_pressed():
	get_tree().change_scene("res://Scenes/GenerateWorldScene.tscn")


func _on_simplebattle_button_pressed():
	var battle_scene = MemoryTileBattleScene.instance()
	battle_scene.monster_data = {
	"type": "Slime",
	"health": 30,
	"strength": 10,
	"defense": 4,
	"turns": 1,
	"next_round_turns": 1,
	
	"skill_probability": 40, # 40 = 40%
	"skills": {
		# These should add up to 100
		"chomp": 100 # 20%,
	}
}
	
	SceneManagement.change_scene_to(get_tree(), battle_scene)


func _on_AdvancedBattleButton_pressed():
	var battle_scene = MemoryTileBattleScene.instance()
	
	battle_scene.monster_data = {
		"type": "Volture",
		"health": 450,
		"strength": 80,
		"defense": 40,
		"turns": 3,
		"next_round_turns": 3,
		
		"skill_probability": 60,
		"skills": {
			# These should add up to 100
			"chomp": 30,
			"vampire": 40,
			"shock": 30
		}
	};
	
	battle_scene.player = BattlePlayer.new(600, 50, 30, 8, 4)
	battle_scene.go_turbo()
	
	SceneManagement.change_scene_to(get_tree(), battle_scene)
