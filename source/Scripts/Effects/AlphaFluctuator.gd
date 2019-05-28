extends Node2D

"""
Given an object, fluctuate it's alpha (sine wave fluctuation).
"""

signal done

# eg. sin(4x) cycles four times per 2pi instead of once
const CYCLE_FAST_MULTIPLIER = 4

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

# target_runtime is fractional seconds
func run(target_runtime):
	self._enabled = true
	self._target_runtime = target_runtime
	
	while self._total_time < self._target_runtime:
		yield()
		
func _process(delta):
	if self._enabled == true:
		self._total_time += delta
		self._target.modulate.a = abs(sin(CYCLE_FAST_MULTIPLIER * self._total_time))
		
		if self._total_time >= self._target_runtime:
			self._enabled = false
			self._target.modulate.a = 0
			
			self.emit_signal("done")
			
			if len(self._remove_on_done) >= 2:
				var container = self._remove_on_done[0]
				var child_node = self._remove_on_done[1]
				container.remove_child(child_node)
				self._remove_on_done = []

func remove_on_done(container, node):
	self._remove_on_done = [container, node]