extends Node

var width = 0
var height = 0
var _data = [] # Simplest is best. One-dimensional array of length w * h

func _init(width, height):
	self._data = []
	self.width = width
	self.height = height

	# Initialize array with nulls
	for i in range(self.width * self.height):
		self._data.append(null)
	
func load_from(rows):
	self.height = rows.size()
	
	var max_width_seen = rows[0].size();
	for row in rows:
		var row_width = row.size()
		if row_width > max_width_seen:
			max_width_seen = row_width
	
	self.width = max_width_seen
	self._init(self.width, self.height)
	
	for y in range(rows.size()):
		var row = rows[y]
		for x in range(row.size()):
			var element = row[x]
			var index = (y * self.width) + x
			self._data[index] = element
	
	return self
	
func has(x, y):
	var index = self._get_index(x, y)
	return index < self._data.size() and self._data[index] != null
	
func get(x, y):
	var index = self._get_index(x, y)
	return self._data[index]

func set(x, y, item):
	var index = self._get_index(x, y)
	self._data[index] = item
	
func find(item):
	var index = self._data.find(item)
	if index > -1:
		var x = index % self.width
		var y = int(index / self.width)
		return Vector2(x, y)
	else:
		return null # not found

func _get_index(x, y):
	return (y * self.width) + x