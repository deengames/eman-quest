extends WindowDialog

const _NUM_SAVES = 10

func _ready():
	for i in range(_NUM_SAVES):
		var n = i + 1
		$HBoxContainer/Container/ItemList.add_item("File " + str(n))