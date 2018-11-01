extends Node2D

var BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
var MemoryTileBattleScene = preload("res://Scenes/Battle/MemoryTileBattleScene.tscn")
var SaveManager = preload("res://Scripts/SaveManager.gd")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Battle/Monster.tscn")

func _ready():
	$DebugPanel.visible = false

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
	var extra_data = SaveManager.load("test", get_tree())

func _on_DebugButton_pressed():
	$DebugPanel.visible = true


func _on_XButton_pressed():
	$DebugPanel.visible = false


func _on_SequenceBattleCheckButton_toggled(button_pressed):
	Features.FEATURE_MAP["sequence battle triggers"] = button_pressed
	if button_pressed:
			Features.FEATURE_MAP["n-back battle triggers"] = false
			$DebugPanel/NBackTriggerToggle.pressed = false
			
func _on_NBackTriggerToggle_toggled(button_pressed):
		Features.FEATURE_MAP["n-back battle triggers"] = button_pressed
		if button_pressed:
			Features.FEATURE_MAP["sequence battle triggers"] = false
			$DebugPanel/SequenceBattleToggle.pressed = false

func _on_UnlimitedBattleChoicesToggle_toggled(button_pressed):
	Features.FEATURE_MAP["unlimited battle choices"] = button_pressed
