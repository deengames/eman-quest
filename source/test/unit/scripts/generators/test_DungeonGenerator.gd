extends "res://addons/gut/test.gd"

const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const DungeonGenerator = preload("res://Scripts/Generators/DungeonGenerator.gd")
const Room = preload("res://Entities/Room.gd")

func test_generate_doesnt_generate_orphan_doors():
	var maps_to_generate = 10
	 # For test stability. Also includes seed of well-known bug:
	# https://www.pivotaltracker.com/story/show/162568442 
	seed(804429191)
	
	var generator = DungeonGenerator.new()
	var area_types = [AreaType.NORMAL, AreaType.AREA_TYPE.BOSS, AreaType.AREA_TYPE.ENTRANCE]
	
	while maps_to_generate > 0:
		maps_to_generate -= 1
		var submap = Room.new(randi() % 9, randi() % 9)
		submap.area_type = area_types[randi() % len(area_types)]
		var map = generator.generate(submap, [], "Castle")
		
		var ground_map = map.tile_data[0]
		var decoration_map = map.tile_data[2]
		
		# Find all doors. Count the ground tiles around them. There should be two.
		for y in range(decoration_map.height):
			for x in range(decoration_map.width):
				var tile = decoration_map.get_at(x, y)
				if tile == "Door":
					var num_ground_tiles = generator._count_ground_tiles_around(ground_map, x, y)
					assert_eq(num_ground_tiles, 2)