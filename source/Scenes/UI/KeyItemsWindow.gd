extends PopupPanel

# List just takes strings. Keep references to items.
var _all_items = []
var _selected_item = null

func _ready():
	self.popup_exclusive = true
	self._clear_selected_display()
	self._populate_item_list()

func title(value):
	$VBoxContainer/CloseDialogTitlebar.title = value

func _populate_item_list():
	$VBoxContainer/HBoxContainer/ItemList.clear()
	self._all_items = []
	
	for item in Globals.player_data.key_items:
		self._add_item(item)

func _add_item(item):
	var name = item.item_name
	$VBoxContainer/HBoxContainer/ItemList.add_item(name)
	self._all_items.append(item)

func _on_ItemList_nothing_selected():
	self._selected_item = null
	self._clear_selected_display()

func _on_ItemList_item_selected(index):
	var item = self._all_items[index]
	# $Sprite.visible = true
	# Sprite.Texture/Region = ...
	$VBoxContainer/HBoxContainer/VBoxContainer/ItemName.text = item.item_name
	$VBoxContainer/HBoxContainer/VBoxContainer/Description.text = item.description
	self._selected_item = item

func _clear_selected_display():
	$VBoxContainer/HBoxContainer/VBoxContainer/ItemName.text = ""
	$VBoxContainer/HBoxContainer/VBoxContainer/Description.text = ""
