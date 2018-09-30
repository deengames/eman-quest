extends CanvasLayer

const EquipmentWindow = preload("res://Scenes/UI/EquipmentWindow.tscn")
const KeyItemsWindow = preload("res://Scenes/UI/KeyItemsWindow.tscn")
const StatsWindow = preload("res://Scenes/UI/StatsWindow.tscn")
const StoryWindow = preload("res://Scenes/UI/StoryWindow.tscn")

func _ready():
	pass

func show_intro_story():
	var instance = StoryWindow.instance()
	instance.show_intro_story()
	self._show_popup(instance)

func show_ending_story():
	var instance = StoryWindow.instance()
	instance.show_ending_story()
	self._show_popup(instance)

func _on_StatsButton_pressed():
	self._show_popup(StatsWindow.instance())
	
func _on_EquipmentButton_pressed():
	self._show_popup(EquipmentWindow.instance())

func _on_KeyItemsButton_pressed():
	self._show_popup(KeyItemsWindow.instance())

func _show_popup(instance):
	self.add_child(instance)
	instance.popup_centered()