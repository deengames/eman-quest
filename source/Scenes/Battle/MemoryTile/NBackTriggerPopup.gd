extends WindowDialog

const _CHOICES = ['left', 'up', 'right', 'down']
const _NUM_PREVIOUS = 3 # TODO: can vary with difficulty, but risky / super difficult

var num_correct = 0
var _current = 'up'

var _previously_seen = [] # limited to _NUM_PREVIOUS items

func _ready():
	self.popup_exclusive = true
	self._pick_another_item()

func _pick_another_item():
	self._current = _CHOICES[randi() % len(_CHOICES)]
	$Sprite.rotation_degrees = self._rotation_from(self._current)

func _rotation_from(choice):
	if choice == "up": return 0
	elif choice == "right": return 90
	elif choice == "down": return 180
	elif choice == "left": return 270

func _on_YesButton_pressed():
	self._user_chooses(true)

func _on_NoButton_pressed():
	self._user_chooses(false)

func _user_chooses(user_says_item_repeats):
	var is_repeat = self._current in self._previously_seen
	if is_repeat == user_says_item_repeats:
		self.num_correct += 1
		$CorrectLabel.text = "Correct: " + str(self.num_correct)
		
		self._previously_seen.append(self._current)
		if len(self._previously_seen) > _NUM_PREVIOUS:
			self._previously_seen.pop_front()
		self._pick_another_item()
	else:
		self._finish()
		
func _finish():
	$YesButton.visible = false
	$NoButton.visible = false