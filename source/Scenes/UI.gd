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
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")

	# Retrieve the captured image
	var img = get_viewport().get_texture().get_data()
  
	# Flip it on the y-axis (because it's flipped)
	img.flip_y()

	# Create a texture for it
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	var capture = TextureRect.new()

	# Set it to the capture node
	capture.set_texture(tex)
	
	img.save_png("user://screenshot-test.png")