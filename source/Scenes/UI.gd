extends CanvasLayer

const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")
const EquipmentWindow = preload("res://Scenes/UI/EquipmentWindow.tscn")

func _ready():
	pass

func _on_StatsButton_pressed():
	var stats_window = StatsWindow.instance()
	self.add_child(stats_window)
	stats_window.popup_centered()

func _on_EquipmentButton_pressed():
	var equipment_window = EquipmentWindow.instance()
	self.add_child(equipment_window)
	equipment_window.popup_centered()