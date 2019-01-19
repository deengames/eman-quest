extends "StaticMap.gd"

const map_type = "Final"

func _ready():
	var player = Globals.player
	player.position = $Locations/Entrance.position
	
	if Globals.bosses_defeated >= 3:
		$Umayyah.visible = true
		$Umayyah.face_up()