extends CanvasLayer

const EquipmentWindow = preload("res://Scenes/UI/EquipmentWindow.tscn")
const KeyItemsWindow = preload("res://Scenes/UI/KeyItemsWindow.tscn")
const SaveManager = preload("res://Scripts/SaveManager.gd")
const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")

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

func _on_SaveButton_pressed():
	SaveManager.save("test")
	_capture_screenshot()
	
func _capture_screenshot():
	# Retrieve the captured image
	var image = get_viewport().get_texture().get_data()
	
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	
	image.save_png("user://screenshot-test.png")