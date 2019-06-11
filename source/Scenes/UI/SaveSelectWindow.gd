extends WindowDialog

const SaveManager = preload("res://Scripts/SaveManager.gd")

var _selected_slot = null
var _save_disabled = false # for titlescreen only

func _ready():
	for i in range(Globals.NUM_SAVES):
		var n = i + 1
		$HBoxContainer/Container/ItemList.add_item("File " + str(n))
	
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.hide()
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.hide()

func disable_saving():
	_save_disabled = true
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.hide()

func _on_ItemList_item_selected(index):
	_selected_slot = index

	var label = $HBoxContainer/Container2/SaveDetailsPanel/StatsLabel
	var sprite = $HBoxContainer/Container2/SaveDetailsPanel/ScreenshotSprite
	var save_exists = SaveManager.save_exists("save" + str(index))
	
	if _save_disabled: # we're loading
		$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.disabled = not save_exists
	else:
		$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.show()
		
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.visible = save_exists
	
	if save_exists:
		# get data blob based on `index`
		label.text = "World: #123456789\nPlay time: 0:30:13\nLevel: 7"
		sprite.texture = _get_screenshot_for(index)
	else:
		label.text = "Empty"
		sprite.texture = null
		
func _get_screenshot_for(index):

	var file = File.new()
	file.open(_screenshot_path(index), File.READ)
	var buffer = file.get_buffer(file.get_len())
	file.close()
	
	var image = Image.new()
	image.load_png_from_buffer(buffer)
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	
	return image_texture

func _on_SaveButton_pressed():
	if not _save_disabled and _selected_slot != null:
		SaveManager.save("save" + str(_selected_slot))
		
		# Copy screenshot from last-saved to this slot
		
		var last_screenshot_path = Globals.LAST_SCREENSHOT_PATH
		var file = File.new()
		file.open(last_screenshot_path, File.READ)
		var bytes = file.get_buffer(file.get_len())
		file.close()
		
		file = File.new()
		file.open(_screenshot_path(_selected_slot), File.WRITE)
		file.store_buffer(bytes)
		file.close()
		
		$HBoxContainer/Container2/SaveDetailsPanel/ScreenshotSprite.texture = _get_screenshot_for(_selected_slot)
		
func _screenshot_path(save_id):
	return "user://screenshot-save" + str(save_id) + ".png"

func _on_LoadButton_pressed():
	if _selected_slot != null:
		# Wait just long enough for the scene to display, then generate
		yield(get_tree().create_timer(0.25), 'timeout')
		SaveManager.load("save" + str(_selected_slot), get_tree())