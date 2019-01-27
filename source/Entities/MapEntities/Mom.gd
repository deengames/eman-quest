extends Node2D

func appear_wounded():
	$Dead.visible = true
	$Alive.visible = false