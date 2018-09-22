extends WindowDialog

# List just takes strings. Keep references to items.
var _all_items = []

func _ready():
	self._update_equipped_display()
	$Equipment/SelectedWeapon.text = ""
	$Equipment/SelectedArmour.text = ""
	self._populate_item_list()

func _update_equipped_display():
	$Equipment/CurrentWeapon.text = Globals.player_data.weapon.str()
	$Equipment/CurrentArmour.text = Globals.player_data.armour.str()

func _populate_item_list():
	$ItemList.clear()
	self._all_items = []
	
	_add_item(Globals.player_data.weapon)
	_add_item(Globals.player_data.armour)
	
	for item in Globals.player_data.inventory:
		self._add_item(item)

func _add_item(equipment):
	var name = equipment.equipment_name
	if equipment == Globals.player_data.weapon or equipment == Globals.player_data.armour:
		name = "*" + name
	$ItemList.add_item(name)
	self._all_items.append(equipment)

func _on_ItemList_nothing_selected():
	$ItemList.clear()


func _on_ItemList_item_selected(index):
	var item = self._all_items[index]
	if item.type == "weapon":
		$Equipment/SelectedWeapon.text = item.str()
		$Equipment/SelectedArmour.text = ""
	else: # armour
		$Equipment/SelectedWeapon.text = ""
		$Equipment/SelectedArmour.text = item.str()
