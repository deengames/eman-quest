extends WindowDialog

const _NUM_SYMBOL_CONTROLS = 9
const _TARGET_OPTIONS = [0, 90, 180, 270]
const _DISPLAY_TIME_SECONDS = 1 # seconds
const _FINAL_DISPLAY_TIME_EXTRA = 0.5 # seconds

var _correct = []
var _selected = []

var _controls_to_show = 0
var num_correct = 0
var num_total = _controls_to_show

func _ready():
	self.popup_exclusive = true
	self._controls_to_show = min(Globals.sequence_trigger_difficulty, _NUM_SYMBOL_CONTROLS)
	$React.visible = false
	$Controls.visible = false
	
	self._hide_all_targets()
	yield(get_tree().create_timer(1), 'timeout')
	
	for i in range(1, _controls_to_show + 1):
		var target = _TARGET_OPTIONS[randi() % len(_TARGET_OPTIONS)]
		var node = self.get_node("MonsterChoices/Target" + str(i))
		node.rotation_degrees = target
		node.visible = true
		yield(get_tree().create_timer(_DISPLAY_TIME_SECONDS), 'timeout')
		self._correct.append(target)
	
	yield(get_tree().create_timer(_FINAL_DISPLAY_TIME_EXTRA), 'timeout')
	self._hide_all_targets()
	
	self._hide_all_reacts()
	$React.visible = true
	$Controls.visible = true

func _hide_all_targets():
	for i in range(1, _NUM_SYMBOL_CONTROLS + 1):
		var node = self.get_node("MonsterChoices/Target" + str(i))
		node.visible = false

func _hide_all_reacts():
	for i in range(1, _NUM_SYMBOL_CONTROLS + 1):
		var node = self.get_node("React/Picked" + str(i))
		node.visible = false

func _on_Up_pressed():
	self._user_chooses("up")

func _on_Right_pressed():
		self._user_chooses("right")

func _on_Down_pressed():
		self._user_chooses("down")

func _on_Left_pressed():
		self._user_chooses("left")

func _user_chooses(choice):
	var node_index = len(self._selected)
	self._selected.append(choice)
	
	var target_node = self.get_node("MonsterChoices/Target" + str(node_index + 1))
	var react_control = self.get_node("React/Picked" + str(node_index + 1))
	
	target_node.visible = true
	react_control.visible = true
	react_control.rotation_degrees = _rotation_from(choice)
	
	if is_match(target_node, react_control):
		num_correct += 1
		$CorrectLabel.text = "Correct: " + str(num_correct)
	
	if len(_correct) == len(_selected):
		self._finish()
	
func _finish():
	self._adjust_difficulty()
	$Controls.visible = false

func _adjust_difficulty():
	# 100% right? Make it harder
	if self.num_correct == self._controls_to_show:
		Globals.sequence_trigger_difficulty += 1
	# Less than 50% right? Make it easier. Don't drop below 2.
	elif self.num_correct <= self._controls_to_show / 2 and self._controls_to_show > 2:
		Globals.sequence_trigger_difficulty -= 1

func is_match(target, choice):
	return target.rotation_degrees == choice.rotation_degrees

func _rotation_from(choice):
	if choice == "up": return 0
	elif choice == "right": return 90
	elif choice == "down": return 180
	elif choice == "left": return 270
	