extends KinematicBody2D

func face_down():
	$Sprite.visible = false
	$HumanSpriteUp.visible = false
	$HumanSpriteDown.visible = true
	
func face_up():
	$Sprite.visible = false
	$HumanSpriteUp.visible = true
	$HumanSpriteDown.visible = false