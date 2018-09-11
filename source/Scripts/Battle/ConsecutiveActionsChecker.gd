extends Node

const _PICKS_REQUIRED_FOR_SIGNAL = 3
var _actions_picked = []

signal picked_consecutives

func action_picked(action):
	_actions_picked.append(action)
	if len(self._actions_picked) >= _PICKS_REQUIRED_FOR_SIGNAL:
		for i in range(_PICKS_REQUIRED_FOR_SIGNAL):
			if self._actions_picked[len(self._actions_picked) - 1 - i] != action:
				return
	
		# all picks match
		self.emit_signal("picked_consecutives", action)

func reset():
	self._actions_picked = []