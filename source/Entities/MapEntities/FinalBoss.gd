extends KinematicBody2D

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")

func _ready():
	$Sprite.visible = false
	$HumanSpriteUp.visible = false
	$HumanSpriteDown.visible = false
	$WhiteOut.visible = false
	
func face_down():
	$HumanSpriteUp.visible = false
	$HumanSpriteDown.visible = true
	
func face_up():
	$HumanSpriteUp.visible = true
	$HumanSpriteDown.visible = false

func flicker():
	$WhiteOut.visible = true
	$WhiteOut.modulate.a = 0
	
	var fluc = AlphaFluctuator.new($WhiteOut)
	self.add_child(fluc)
	fluc.run(3)