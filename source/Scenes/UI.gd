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
	
	_hide_ui()
	
	# Need some sort of delay before we save, or they still appear
	# idle_frame itself is not enough; we need two of these before
	# the buttons actually disappear.
	for i in range(2):
		yield(get_tree(), "idle_frame")
	
	_capture_screenshot()
	_show_ui()
	
func _hide_ui():
	# CanvasLayer doesn't have an easy show/hide
	var ui_layer = get_parent().get_node("UI")
	for button in ui_layer.get_children():
		button.hide()

func _show_ui():
	# CanvasLayer doesn't have an easy show/hide
	var ui_layer = get_parent().get_node("UI")
	for button in ui_layer.get_children():
		button.show()
	
func _capture_screenshot():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	# Retrieve the captured image
	var image = get_viewport().get_texture().get_data()
  
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()

	# Create a texture for it
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	# Use a TextureReact to capture data to `texture`
	var capture = TextureRect.new()

	# Set it to the capture node
	capture.set_texture(texture)
	
	image.save_png("user://screenshot-test.png")