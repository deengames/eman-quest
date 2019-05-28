extends Node

const Room = preload("res://Entities/Room.gd")
const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")

const ExtraRooms = 2

###
# Generates multiple rooms and connects them together.
# Forget all that crazy grid stuff we had. Just random walk and make rooms.
# Then do a depth-first search for the longest path; this is entrance => boss.
#
# This typically generates linear dungeons with no branching-off. That's okay.
# Around a third of the dungeons double back or have adjacent rooms/paths.
#
# As a bonus, we add two more rooms and connect each to a random room (other
# than the boss room). This usually adds some non-linearity.
###

static func generate_layout(num_rooms):
	# Overkill but easy to code
	var to_return = TwoDimensionalArray.new(num_rooms, num_rooms)
	var left_to_generate = num_rooms - 1
	
	# Start on one of the edges
	var potential_starts = []
	for x in range(to_return.width):
		potential_starts.append([x, 0])
		potential_starts.append([x, to_return.height - 1])
	for y in range(to_return.height):
		potential_starts.append([0, y])
		potential_starts.append([to_return.width - 1, y])
		
	var coordinates = potential_starts[randi() % len(potential_starts)]
	var x = coordinates[0]
	var y = coordinates[1]
	
	var current = Room.new(x, y)
	current.area_type = AreaType.ENTRANCE
	to_return.set_at(x, y, current)
	var rooms = [current]
	
	
	# Generate the connected graph
	while left_to_generate > 0:
		var next = _pick_unexplored_adjacent(current, to_return)
		if next != null:
			var room = Room.new(next.x, next.y)
			to_return.set_at(next.x, next.y, room)
			current.connect(room)
			rooms.append(room)
			left_to_generate -= 1
			current = room
		else:
			# Nothing available; pick random room
			current = rooms[randi() % len(rooms)]
	
	# Last room is the boss room
	rooms[-1].area_type = AreaType.BOSS
	
	# Attach more random rooms to any rooms (including each other).
	# They don't connect to the boss room, though.
	var extra_rooms = ExtraRooms
	while extra_rooms > 0:
		var attach_to = rooms[randi() % len(rooms)]
		if attach_to.area_type != AreaType.BOSS:
			var next = _pick_unexplored_adjacent(attach_to, to_return)
			if next != null:
				var room = Room.new(next.x, next.y)
				to_return.set_at(next.x, next.y, room)
				attach_to.connect(room)
				rooms.append(room)
				extra_rooms -= 1
			
	return rooms

static func _pick_unexplored_adjacent(current, grid):
	var possibilities = []

	if current.grid_x > 0 and not grid.has(current.grid_x - 1, current.grid_y):
		possibilities.append(Vector2(current.grid_x - 1, current.grid_y))

	if current.grid_x < grid.width - 1 and not grid.has(current.grid_x + 1, current.grid_y):
		possibilities.append(Vector2(current.grid_x + 1, current.grid_y))

	if current.grid_y > 0 and not grid.has(current.grid_x, current.grid_y - 1):
		possibilities.append(Vector2(current.grid_x, current.grid_y - 1))

	if current.grid_y < grid.height - 1 and not grid.has(current.grid_x, current.grid_y + 1):
		possibilities.append(Vector2(current.grid_x, current.grid_y + 1))

	if len(possibilities) > 0:
		var to_return = possibilities[randi() % len(possibilities)]
		return to_return
	else:
		return null
		