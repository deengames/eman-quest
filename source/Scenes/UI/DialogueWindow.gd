extends Node2D

signal shown_all

const Quest = preload("res://Entities/Quest.gd")

var speaker_name setget set_speaker_name, get_speaker_name
var dialogue setget set_dialogue, get_dialogue

var _showing_texts = false
var _texts = []
var _showing_index = -1

var _map_names = []

func _ready():
	$Avatar/Sprite.texture = null
	self.speaker_name = ""
	self.dialogue = ""
	self.z_index = 4096 # always be on top
	
	# Center automagically on-screen. If there's a Player entity in this scene.
	var viewport = get_viewport_rect().size
	# Second null check: is player NOT previously freed?
	if Globals.player != null and Globals.pre_battle_position == null:
		var camera_position = Globals.player.get_node("Camera2D").global_position
		# Pure magic. This calculation makes no sense to me.
		self.position = camera_position - (viewport / 4)
	
	# parse all map names. for substituting {map<n>} tokens in text.
	for map_name in Globals.world_areas:
		var divider_index = map_name.find('/')
		var map_type = map_name.substr(0, divider_index)
		var variation = map_name.substr(divider_index + 1, len(map_name))
		var friendly_name = variation + " " + map_type
		self._map_names.append(friendly_name)

func show_texts(texts):
	self.set_process_input(true) # block player from moving by clicking
	self._texts = texts
	self._showing_texts = true
	self._showing_index = -1
	self.visible = true
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
				self.visible = false
				self.emit_signal("shown_all")
		
func show_text(speaker, content):
	self.speaker_name = speaker
	
	content = content.replace("{finalmap}", Quest.FINAL_MAP_NAME)
	
	for i in range(len(self._map_names)):
		var map_token = "{map" + str(i + 1) + "}"
		var map_name = self._map_names[i]
		content = content.replace(map_token, map_name)
	
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