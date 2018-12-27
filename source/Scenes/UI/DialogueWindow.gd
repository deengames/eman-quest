extends Node2D

signal shown_all

var speaker_name setget set_speaker_name, get_speaker_name
var dialogue setget set_dialogue, get_dialogue

var _showing_texts = false
var _texts = []
var _showing_index = -1

func _ready():
	self.set_process_input(true) # block player from moving by clicking
	$Avatar/Sprite.texture = null
	self.speaker_name = ""
	self.dialogue = ""

func show_texts(texts):
	self._texts = texts
	_showing_texts = true
	# Each text is a tuple of (speaker, content)
	# Pressing space or clicking advances to the next one.
	self._show_next_text()

func _input(event):
	if _showing_texts:
		if (
			(event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion) or
			(event is InputEventKey and event.pressed and event.scancode == KEY_SPACE)
		):
			# Advance to the next text
			if self._showing_index < len(self._texts) - 1:
				self._show_next_text()
			else:
				# Last scene DONE, close
				self._showing_texts = false
				self.emit_signal("shown_all")
				self.visible = false
		
func show_text(speaker, content):
	self.speaker_name = speaker
	self.dialogue = content

func set_speaker_name(speaker):
	$Nametag/NameText.text = speaker

func get_speaker_name():
	return $Nametag/NameText.text
	
func set_dialogue(content):
	$Panel/DialogueText.text = content
	
func get_dialogue():
	return $Panel/DialogueText.text

func _show_next_text():
	self._showing_index += 1
	var data = self._texts[self._showing_index]
	self.show_text(data[0], data[1])