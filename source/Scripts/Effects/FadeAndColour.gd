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