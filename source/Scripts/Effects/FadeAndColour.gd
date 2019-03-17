extends Node2D

"""
Given an object, fade out and fade to black.
"""

signal done

var _white = Color("#ffffff")
var _enabled = false
var _total_time = 0 # will eventually overflow ...
var _target
var _target_runtime = 0
var _remove_on_done = [] # container, child_node

func _init(target):
	self._target = target

func start():
	self._enabled = true

func stop():
	self._enabled = false

func run(target_runtime):
	self._enabled = true
	self._target_runtime = target_runtime
	
	while self._total_time < self._target_runtime:
		yield()
		
func _process(delta):
	if self._enabled == true:
		self._total_time += delta
		# Added to colour. Also used as alpha.
		var rgb = self._total_time / self._target_runtime
		if (rgb > 1): rgb = 1
		self._target.modulate = self._white.darkened(rgb)
		self._target.modulate.a = 1 - rgb # fade out over time
	if self._total_time >= self._target_runtime:
		self._enabled = false
		self._target.modulate = Color(0, 0, 0, 0)
		self.emit_signal("done")
		
		if len(self._remove_on_done) >= 2:
			var container = self._remove_on_done[0]
			var child_node = self._remove_on_done[1]
			container.remove_child(child_node)
			self._remove_on_done = []

func remove_on_done(container, node):
	self._remove_on_done = [container, node]