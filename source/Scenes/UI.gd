extends CanvasLayer

const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")

func _ready():
	pass

func _on_StatsButton_pressed():
	var stats_window = StatsWindow.instance()
	self.add_child(stats_window)
	stats_window.popup_centered()
