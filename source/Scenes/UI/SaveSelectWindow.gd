extends WindowDialog

const _NUM_SAVES = 10

func _ready():
	for i in range(_NUM_SAVES):
		var n = i + 1
		$HBoxContainer/Container/ItemList.add_item("File " + str(n))

func _on_ItemList_item_selected(index):
	# get data blob based on `index`
	$HBoxContainer/Container2/SaveDetailsPanel/StatsLabel.text = "World: #123456789\nPlay time: 0:30:13\nLevel: 7"
