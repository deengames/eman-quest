extends "res://addons/gut/test.gd"

const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const GenerateWorldScene = preload("res://Scenes/GenerateWorldScene.gd")
const MapLayoutGenerator = preload("res://Scripts/Generators/MapLayoutGenerator.gd")
const Room = preload("res://Entities/Room.gd")

func test_generate_layout_attaches_extra_rooms_to_non_boss_rooms():
	for i in range(1000):
		# Act
		var rooms = MapLayoutGenerator.generate_layout(GenerateWorldScene._SUBMAPS_PER_AREA)
		
		# Assert
		# We know that the last two rooms are extra rooms
		var extra_rooms = [rooms[-1], rooms[-2]]
		for room in extra_rooms:
			assert_ne(room.area_type, AreaType.BOSS)