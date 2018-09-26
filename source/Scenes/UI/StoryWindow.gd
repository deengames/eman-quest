extends WindowDialog

const SceneManagement = preload("res://Scripts/SceneManagement.gd")

var _on_close_callback = null

func show_intro_story():
	self.window_title = "A New Adventure Begins!"
	var village_name = Globals.story_data["village_name"]
	var final_boss_type = Globals.story_data["boss_type"]
	$Contents.text = "A young boy from the village of " + village_name + " wakes up one day to find an enourmous " + final_boss_type + " creature emerge and kidnap the village imam. The creature flees toward the forest."
	self._on_close_callback = funcref(self, "_change_to_overworld_map")

func _change_to_overworld_map():
	SceneManagement.change_map_to(get_tree(), "Overworld")

func _on_Node2D_popup_hide():
	if self._on_close_callback != null:
		self._on_close_callback.call_func()
		self._on_close_callback = null

func _on_CloseButton_pressed():
	self.emit_signal("popup_hide")
