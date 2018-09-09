extends KinematicBody2D

var _cant_fight_from = null
var CANT_FIGHT_FOR_SECONDS = 5

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	Globals.player = self

func temporarily_no_battles():
	self._cant_fight_from = OS.get_ticks_msec()

func _process(delta):
	var now = OS.get_ticks_msec()
	if self._cant_fight_from != null and (now - self._cant_fight_from) / 1000 >= CANT_FIGHT_FOR_SECONDS:
		self._cant_fight_from = null

func can_fight():
	return self._cant_fight_from == null