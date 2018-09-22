extends WindowDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	self._update_equipped_display()
	$Equipment/SelectedWeapon.text = ""
	$Equipment/SelectedArmour.text = ""
	self._populate_item_list()

func _update_equipped_display():
	$Equipment/CurrentWeapon.text = Globals.player_data.weapon.str()
	$Equipment/CurrentArmour.text = Globals.player_data.armour.str()

func _populate_item_list():
	$ItemList.add_item(Globals.player_data.weapon.equipment_name)
	$ItemList.add_item(Globals.player_data.armour.equipment_name)
	
	for item in Globals.player_data.inventory:
		$ItemList.add_item(item.equipment_name)