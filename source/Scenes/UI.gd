extends CanvasLayer

const EquipmentWindow = preload("res://Scenes/UI/EquipmentWindow.tscn")
const KeyItemsWindow = preload("res://Scenes/UI/KeyItemsWindow.tscn")
const SaveManager = preload("res://Scripts/SaveManager.gd")
const SaveSelectWindow = preload("res://Scenes/UI/SaveSelectWindow.tscn")
const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")

signal opened_save_manager
signal closed_save_manager

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
	var save_picker = SaveSelectWindow.instance()
	save_picker.connect("popup_hide", self, "_closed_save_manager")
	add_child(save_picker)
	save_picker.popup_centered()
	
	# We save here because it's the only way to get a screenshot without UI elements	
	_capture_screenshot()
	
	emit_signal("opened_save_manager")

func _closed_save_manager():
	emit_signal("closed_save_manager")

func _capture_screenshot():
	# Retrieve the captured image
	var image = get_tree().get_root().get_texture().get_data()
	
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	
	image.save_png(Globals.LAST_SCREENSHOT_PATH)