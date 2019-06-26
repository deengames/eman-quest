extends CanvasLayer

const EquipmentWindow = preload("res://Scenes/UI/EquipmentWindow.tscn")
const KeyItemsWindow = preload("res://Scenes/UI/KeyItemsWindow.tscn")
const SaveManager = preload("res://Scripts/SaveManager.gd")
const SaveSelectWindow = preload("res://Scenes/UI/SaveSelectWindow.tscn")
const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")

signal opened_save_manager
signal closed_save_manager

func _on_StatsButton_pressed():
	self._show_popup(StatsWindow.instance(), "Player Stats")
	
func _on_EquipmentButton_pressed():
	self._show_popup(EquipmentWindow.instance(), "Equipment")

func _on_KeyItemsButton_pressed():
	self._show_popup(KeyItemsWindow.instance(), "Key Items")

func _show_popup(instance, title):
	Globals.player.freeze()
	instance.popup_exclusive = true
	instance.connect("popup_hide", self, "_unfreeze_all")
	instance.title(title)
	get_parent().freeze_monsters()
	self.add_child(instance)
	instance.popup_centered()

func _on_SaveButton_pressed():
	Globals.player.freeze()
	
	# We save here because it's the only way to get a screenshot without UI elements	
	_capture_screenshot()
	
	var save_picker = SaveSelectWindow.instance()
	save_picker.connect("popup_hide", self, "_closed_save_manager")
	_show_popup(save_picker, "Save/Load Game")
	
	emit_signal("opened_save_manager")

func _closed_save_manager():
	emit_signal("closed_save_manager")
	_remove_ui_dialogs()
	_unfreeze_all()

func _unfreeze_all():
	Globals.player.unfreeze()
	get_parent().unfreeze_monsters()
	_remove_ui_dialogs()

func _remove_ui_dialogs():
	# Correctly shows UI, but also re-shows dialog manager
	# le sigh, UNSHOW dialog manager
	for child in get_children():
		if child is Popup:
			remove_child(child)

func _capture_screenshot():
	# Retrieve the captured image
	var image = get_tree().get_root().get_texture().get_data()
	
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	
	image.save_png(Globals.LAST_SCREENSHOT_PATH)