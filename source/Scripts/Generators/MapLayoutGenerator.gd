extends Node

const Room = preload("res://Entities/Room.gd")
const TwoDimensionalArray = preload("res://Scripts/TwoDimensionalArray.gd")

###
# Generates multiple rooms and connects them together.
# Forget all that crazy grid stuff we had. Just random walk and make rooms.
# Then do a depth-first search for the longest path; this is entrance => boss.
#
# Mutliple paths may mean we find a short route to boss. That's ok. Maybe
# some players want that challenge.
###

static func generate_layout(num_rooms):
	# Overkill but easy to code
	var to_return = TwoDimensionalArray.new(num_rooms, num_rooms)
	var left_to_generate = num_rooms
	
	var x = randi() % to_return.width
	var y = randi() % to_return.height
	var current = Room.new(x, y)
	to_return.set(x, y, current)
	var rooms = [current]

	while left_to_generate > 0:
		var next = _pick_unexplored_adjacent(current, to_return)
		if next != null:
			var room = Room.new(next.x, next.y)
			to_return.set(next.x, next.y, room)
			current.connect(room)
			rooms.append(room)
			left_to_generate -= 1
			current = room
		else:
			# Nothing available; pick random room
			current = rooms[randi() % len(rooms)]

	var final = ""
	for y in range(num_rooms):
		var string = ""
		for x in range(num_rooms):
			if to_return.has(x, y):
				string += "."
			else:
				string += " "
		final += string + "\n"

	print(final)

	return to_return

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
		