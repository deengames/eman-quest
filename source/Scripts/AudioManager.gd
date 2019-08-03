extends Node

signal sound_finished

const AudioFilePlayerClass = preload("res://Scenes/AudioFilePlayer.tscn")
var AudioManger = get_script()

const BACKGROUND_AUDIOS = ["home", "waterfall-cliff", "title", "credits"]

###### SOURCE: https://godot.readthedocs.io/en/3.0/tutorials/3d/fps_tutorial/part_six.html#doc-fps-tutorial-part-six
# ------------------------------------
# All of the audio files.

# You will need to provide your own sound files.
var audio_clips = {
	# Qur'an audios
	"quran-intro-1": preload("res://assets/audio/quran-17-23.ogg"),
	"quran-intro-2": preload("res://assets/audio/quran-17-24.ogg"),
	"quran-finale-1": preload("res://assets/audio/quran-14-41.ogg"),
	"quran-finale-2": preload("res://assets/audio/quran-14-42.ogg"),
	
	# Dungeon background audios
	"slime-forest-bgs": preload("res://assets/audio/bgs/Slime-Forest.ogg"),
	"frost-forest-bgs": preload("res://assets/audio/bgs/Frost-Forest.ogg"),
	"death-forest-bgs": preload("res://assets/audio/bgs/Death-Forest.ogg"),
	"river-cave-bgs": preload("res://assets/audio/bgs/River-Cave.ogg"),
	"lava-cave-bgs": preload("res://assets/audio/bgs/Lava-Cave.ogg"),
	"castle-dungeon-bgs": preload("res://assets/audio/bgs/Castle-Dungeon.ogg"),
	"desert-dungeon-bgs": preload("res://assets/audio/bgs/Desert-Dungeon.ogg"),
	
	# Static map background audios
	"waterfall-cliff": preload("res://assets/audio/bgs/Waterfall-Cliff.ogg"),
	"home": preload("res://assets/audio/bgs/Home.ogg"),
	
	# Title/credits
	"title": preload("res://assets/audio/bgs/Title.ogg"),
	"credits": preload("res://assets/audio/bgs/Credits.ogg"),
	
	# SFX
	"button-click": preload("res://assets/audio/sfx/button-click.ogg"),
	"open-treasure-chest": preload("res://assets/audio/sfx/open-treasure-chest.ogg"),
	"save": preload("res://assets/audio/sfx/save.ogg"),
	"load": preload("res://assets/audio/sfx/load.ogg"),
	"dog-barking": preload("res://assets/audio/sfx/friendly-bark.ogg"),
	"open-metal-door": preload("res://assets/audio/sfx/open-metal-door.ogg"),
	"open-wood-door": preload("res://assets/audio/sfx/open-wood-door.ogg"),
	
	# Battle sounds
	"right-tile": preload("res://assets/audio/sfx/right-tile.ogg"),
	"wrong-tile": preload("res://assets/audio/sfx/wrong-tile.ogg"),
	"battle-transition": preload("res://assets/audio/sfx/battle-transition.ogg"),
	"tech-point": preload("res://assets/audio/sfx/tech-point.ogg"),

	# Battle sounds - player
	"attack": preload("res://assets/audio/sfx/battle/attack.ogg"),
	"critical": preload("res://assets/audio/sfx/battle/critical.ogg"),
	"defend": preload("res://assets/audio/sfx/battle/defend.ogg"),
	"heal": preload("res://assets/audio/sfx/battle/potion.ogg"),
	"vampire": preload("res://assets/audio/sfx/battle/vampire.ogg"),
	"bash": preload("res://assets/audio/sfx/battle/stun.ogg"),
	
	# Battle sounds - monster
	"monster-attack": preload("res://assets/audio/sfx/battle/monster-attack.ogg"),
	"chomp": preload("res://assets/audio/sfx/battle/chomp.ogg"),
	"roar": preload("res://assets/audio/sfx/battle/roar.ogg"),
	"howl": preload("res://assets/audio/sfx/battle/howl.ogg"),
	"freeze": preload("res://assets/audio/sfx/battle/freeze.ogg"),
	"poison": preload("res://assets/audio/sfx/battle/poison.ogg"),
	"pierce": preload("res://assets/audio/sfx/battle/pierce.ogg"),
	"harden": preload("res://assets/audio/sfx/battle/harden.ogg"),
	"eat": preload("res://assets/audio/sfx/battle/eat.ogg"),
	"armour-break": preload("res://assets/audio/sfx/battle/armour-break.ogg"),
	"shield-bash": preload("res://assets/audio/sfx/battle/shield-bash.ogg"),
	"fireball": preload("res://assets/audio/sfx/battle/fireball.ogg"),
	"100-needles": preload("res://assets/audio/sfx/battle/100-needles.ogg"),
	
	# Event sounds
	"scream": preload("res://assets/audio/sfx/scream.ogg"),
	"pick-up": preload("res://assets/audio/sfx/pick-up.ogg"),
	"give-items": preload("res://assets/audio/sfx/give-items.ogg"),
	"teleport": preload("res://assets/audio/sfx/teleport.ogg"),
	"merge": preload("res://assets/audio/sfx/merge.ogg"),
	"unmerge": preload("res://assets/audio/sfx/unmerge.ogg")
}

var audio_instances = []

func add_click_noise_to_controls(scene):
	for control in scene.get_children():
		if control is Button or control is CheckButton:
			control.connect("pressed", self, "_play_button_click")
		elif len(control.get_children()) > 0:
			add_click_noise_to_controls(control)

func _play_button_click():
	play_sound("button-click")

func play_sound(audio_clip_key, volume_db = 0):
	if audio_clips.has(audio_clip_key):
		var audio_player = AudioFilePlayerClass.instance()
		var bus = "SFX"
		if "bgs" in audio_clip_key or audio_clip_key in BACKGROUND_AUDIOS or audio_clip_key == "credits":
			bus = "Background"
		
		Globals.add_child(audio_player)
		audio_player.set_bus(bus)
		audio_instances.append(audio_player)
		
		audio_player.should_loop = false
		audio_player.play_sound(audio_clips[audio_clip_key], volume_db)
		audio_player.connect("finished", self, "_sound_finished")
	else:
		print ("ERROR: cannot play sound {key} that is not defined in audio_clips dictionary!".format({key = audio_clip_key}))
# ------------------------------------

func remove_sound(audio):
	var index = audio_instances.find(audio)
	audio_instances.remove(index)

func clean_up_audio():
	for sound in audio_instances:
		if (sound != null):
			sound.queue_free()
		
	audio_instances.clear()

###
# If this isn't firing, check that your .ogg doesn't show Loop checked under Import
# (next to Scene tab, top-right of Godot 3.0 editor).
# If it does, uncheck and click Reimport.
###
func _sound_finished(audio):
	self.remove_sound(audio)
	self.emit_signal("sound_finished")