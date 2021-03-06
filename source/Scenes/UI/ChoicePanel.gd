extends Node2D

const AudioManager = preload("res://Scripts/AudioManager.gd")

signal on_yes
signal on_no

func show_text(text, confirm_text = "Yes", cancel_text = "No"):
	# Doesn't take into account camera
	var viewport = get_viewport_rect().size
	self.position = viewport / 2
	self.z_index = 999
	
	$Label.text = text
	$YesButton.text = confirm_text
	$NoButton.text = cancel_text
	
	AudioManager.new().add_click_noise_to_controls(self)
	
func _on_YesButton_pressed():
	self.emit_signal("on_yes")
	self.queue_free()

func _on_NoButton_pressed():
	self.emit_signal("on_no")
	self.queue_free()
