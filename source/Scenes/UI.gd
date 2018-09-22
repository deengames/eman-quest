extends CanvasLayer

const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")
const InventoryWindow = preload("res://Scenes/UI/InventoryWindow.tscn")

func _ready():
	pass

func _on_StatsButton_pressed():
	var stats_window = StatsWindow.instance()
	self.add_child(stats_window)
	stats_window.popup_centered()


func _on_InventoryButton_pressed():
	var inventory_window = InventoryWindow.instance()
	self.add_child(inventory_window)
	inventory_window.popup_centered()