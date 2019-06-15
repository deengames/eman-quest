extends WindowDialog

const AudioManager = preload("res://Scripts/AudioManager.gd")

# List just takes strings. Keep references to items.
var _all_items = []
var _selected_item = null

func _ready():
	self.popup_exclusive = true
	self._update_equipped_display()
	self._clear_selected_display()
	self._populate_item_list()
	$EquipButton.disabled = true
	AudioManager.new().add_click_noise_to_controls(self)

func _update_equipped_display():
	$Equipment/CurrentWeapon.text = Globals.player_data.weapon.str()
	$Equipment/CurrentArmour.text = Globals.player_data.armour.str()

func _populate_item_list():
	$ItemList.clear()
	self._all_items = []
	
	_add_item(Globals.player_data.weapon)
	_add_item(Globals.player_data.armour)
	
	for item in Globals.player_data.equipment:
		self._add_item(item)

func _add_item(equipment):
	var name = equipment.equipment_name
	if equipment == Globals.player_data.weapon or equipment == Globals.player_data.armour:
		name = "*" + name
	$ItemList.add_item(name)
	self._all_items.append(equipment)

func _on_ItemList_nothing_selected():
	# Unselect item. Probably a Godot bug that it still looks selected.
	# Bug opened: https://github.com/godotengine/godot/issues/26895
	for i in range(len(self._all_items)):
		$ItemList.unselect(i)
		
	$EquipButton.disabled = true
	self._selected_item = null
	self._clear_selected_display()
	

func _on_ItemList_item_selected(index):
	var item = self._all_items[index]
	
	if item.type == "weapon":
		$Equipment/SelectedWeapon.text = item.str()
		$Equipment/SelectedArmour.text = ""
	elif item.type == "armour":
		$Equipment/SelectedWeapon.text = ""
		$Equipment/SelectedArmour.text = item.str()
	
	$EquipButton.disabled = false
	self._selected_item = item
	
func _on_EquipButton_pressed():
	if self._selected_item != null: # redundant but safer
		if self._selected_item.type == "weapon":
			var old_weapon = Globals.player_data.weapon
			Globals.player_data.equipment.append(old_weapon)
			Globals.player_data.weapon = self._selected_item
		elif self._selected_item.type == "armour":
			var old_armour = Globals.player_data.armour
			Globals.player_data.equipment.append(old_armour)
			Globals.player_data.armour = self._selected_item
		
		var index = Globals.player_data.equipment.find(self._selected_item)
		Globals.player_data.equipment.remove(index)
		self._selected_item = null
		
		$EquipButton.disabled = true
		self._clear_selected_display()
		self._update_equipped_display()
		self._populate_item_list()

func _clear_selected_display():
	$Equipment/SelectedWeapon.text = ""
	$Equipment/SelectedArmour.text = ""