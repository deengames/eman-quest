extends Node2D

var speaker_name setget set_speaker_name, get_speaker_name
var dialogue setget set_dialogue, get_dialogue

func _ready():
	$Avatar/Sprite.texture = null
	self.speaker_name = ""
	self.dialogue = ""

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