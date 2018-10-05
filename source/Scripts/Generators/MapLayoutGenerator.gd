extends Node

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
	var middle = floor(num_rooms / 2)

	var left_to_generate = num_rooms
	var current = Vector2(randi() % num_rooms, randi() % num_rooms)
	to_return.set(current.x, current.y, true)
	var rooms = [current]

	while left_to_generate > 0:
		var next = _pick_unexplored_adjacent(current, to_return)
		if next != current:
			# TODO: we know they're adjacent. Note the connection ya3ne.
			to_return.set(next.x, next.y, true)
			rooms.append(next)
			left_to_generate -= 1
			current = next
		else:
			# Nothing available; pick random room
			current = rooms[randi() % len(rooms)]
			print("!")

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

	if current.x > 0 and not grid.has(current.x - 1, current.y):
		possibilities.append(Vector2(current.x - 1, current.y))

	if current.x < grid.width - 1 and not grid.has(current.x + 1, current.y):
		possibilities.append(Vector2(current.x + 1, current.y))

	if current.y > 0 and not grid.has(current.x, current.y - 1):
		possibilities.append(Vector2(current.x, current.y - 1))

	if current.y < grid.height - 1 and not grid.has(current.x, current.y + 1):
		possibilities.append(Vector2(current.x, current.y + 1))

	if len(possibilities) > 0:
		var to_return = possibilities[randi() % len(possibilities)]
		return to_return
	else:
		return current
		