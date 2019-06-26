extends PopupPanel

const AudioManager = preload("res://Scripts/AudioManager.gd")
const PlayerData = preload("res://Entities/PlayerData.gd")
const SaveManager = preload("res://Scripts/SaveManager.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")

var _selected_slot = null
var _save_disabled = false # for titlescreen only

func _ready():
	for i in range(Globals.NUM_SAVES):
		var n = i + 1
		$HBoxContainer/Container/ItemList.add_item("File " + str(n))
	
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.hide()
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.hide()
	AudioManager.new().add_click_noise_to_controls($HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer)
	
func disable_saving():
	# From titlescreen we came, and to it we will return on close.
	_save_disabled = true
	$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.hide()
	
	self.connect("popup_hide", self, "_back_to_titlescreen")

func title(value):
	$CloseDialogTitlebar.title = value

func _back_to_titlescreen():
	var tree = get_tree()
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	tree.change_scene("res://Scenes/Title.tscn")

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
		var data = SaveManager.load_data("save" + str(index))
		
		label.text = "World: #{seed}\nPlay time: {play_time}\nLevel: {level}" \
			.format({
				"seed": str(data["seed_value"]),
				"play_time": PlayerData.seconds_to_time(data["player_data"].play_time_seconds),
				"level": int(data["player_data"].level)
			})
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
	
	image_texture.flags = 0 # turn off "Filter"
	
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
		
		# Refresh so it LOOKS saved
		_on_ItemList_item_selected(_selected_slot)
		
func _screenshot_path(save_id):
	return "user://screenshot-save" + str(save_id) + ".png"

func _on_LoadButton_pressed():
	if _selected_slot != null:
		$HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.disabled = true
		# disappear without triggering popup_hide, which takes us to the titlescreen
		self.modulate.a = 0 
		SaveManager.load("save" + str(_selected_slot), get_tree())
