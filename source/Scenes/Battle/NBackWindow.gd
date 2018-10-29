extends WindowDialog

const _NUM_SYMBOL_CONTROLS = 7
const _CONTROLS_TO_SHOW = 4 # TODO: adaptive difficulty
const _TARGET_OPTIONS = [0, 90, 180, 270]
const _DISPLAY_TIME_SECONDS = 1 # seconds
const _FINAL_DISPLAY_TIME_EXTRA = 0.5 # seconds

var _correct = []

func _ready():
	
	self._hide_all()
	yield(get_tree().create_timer(1), 'timeout')
	
	for i in range(1, _CONTROLS_TO_SHOW):
		var target = _TARGET_OPTIONS[randi() % len(_TARGET_OPTIONS)]
		var node = self.get_node("MonsterChoices/Target" + str(i))
		node.rotation_degrees = target
		node.visible = true
		yield(get_tree().create_timer(_DISPLAY_TIME_SECONDS), 'timeout')
		self._correct.append(target)
	
	yield(get_tree().create_timer(_FINAL_DISPLAY_TIME_EXTRA), 'timeout')
	self._hide_all()

func _hide_all():
	for i in range(1, _NUM_SYMBOL_CONTROLS + 1):
		var node = self.get_node("MonsterChoices/Target" + str(i))
		node.visible = false