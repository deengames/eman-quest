extends CanvasLayer

const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")
const EquipmentWindow = preload("res://Scenes/UI/EquipmentWindow.tscn")
const KeyItemsWindow = preload("res://Scenes/UI/KeyItemsWindow.tscn")

func _ready():
	pass

func _on_StatsButton_pressed():
	self._show_popup(StatsWindow.instance())
	
func _on_EquipmentButton_pressed():
	self._show_popup(EquipmentWindow.instance())

func _on_KeyItemsButton_pressed():
	self._show_popup(KeyItemsWindow.instance())

func _show_popup(instance):
	self.add_child(instance)
	instance.popup_centered()