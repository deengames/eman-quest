extends Node2D

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")

signal done

func glow(seconds):
	$WhiteOut.visible = true
	$WhiteOut.modulate.a = 0
	
	var fluc = AlphaFluctuator.new($WhiteOut)
	self.add_child(fluc)
	fluc.connect("done", self, "_on_glow_done")
	fluc.run(seconds)

func _on_glow_done():
	self.emit_signal("done")
	
func show_defeat_events():
	pass