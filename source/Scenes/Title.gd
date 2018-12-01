extends Node2D

var BattlePlayer = preload("res://Entities/Battle/BattlePlayer.gd")
var SceneManagement = preload("res://Scripts/SceneManagement.gd")
var Slime = preload("res://Entities/Battle/Monster.tscn")

func _ready():
	$DebugPanel.visible = false

func _on_newgame_Button_pressed():
	get_tree().change_scene("res://Scenes/GenerateWorldScene.tscn")

func _on_LoadGameButton_pressed():
	get_tree().change_scene("res://Scenes/LoadingScene.tscn")

func _on_DebugButton_pressed():
	$DebugPanel.visible = true

func _on_XButton_pressed():
	$DebugPanel.visible = false

func _on_SequenceBattleCheckButton_toggled(button_pressed):
	Features.set("sequence battle triggers", button_pressed)
	if button_pressed:
			Features.set("n-back battle triggers", false)
			$DebugPanel/NBackTriggerToggle.pressed = false
			
func _on_NBackTriggerToggle_toggled(button_pressed):
		Features.set("n-back battle triggers", button_pressed)
		if button_pressed:
			Features.set("sequence battle triggers", false)
			$DebugPanel/SequenceBattleToggle.pressed = false

func _on_UnlimitedBattleChoicesToggle_toggled(button_pressed):
	Features.set("unlimited battle choices", button_pressed)

func _on_ZoomOutToggle_toggled(button_pressed):
	Features.set("zoom-out maps", button_pressed)

func _on_StreamlinedBattleEnemyTriggersToggle_toggled(button_pressed):
	Features.set("streamlined battles: enemy triggers", button_pressed)


func _on_StreamlinedBattlesToggle_toggled(button_pressed):
		Features.set("streamlined battles", button_pressed)
