extends Node2D

const _SHOW_TIME_MILLISECONDS = 1500 # 1000 = 1s
const _WRONG_ACTION_PROBABILITY = 0.4 # 0.5 = 50% probability
const ENERGY_X = 448
const _PROBABILITY_OF_ADVANCED_TILE = 25 # 25 = 25%

signal tile_selected

var created_on = 0

var contents = ""
var state = ""
var width = 0
var height = 0

var tile_x = 0
var tile_y = 0

var show_advanced_actions = false

var do_not_change = false

# open/close x coordinates
var frames = {
	"closed": 0,
	"open": 64
}

const Actions = {
	"attack": 0,
	"critical": 64,
	#"defend": 128,
	"heal": 192
}

const AdvancedActions = {
	"vampire": 320,
	"bash": 384
}

const WRONG_IMAGE_X = 256

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.width = $Cover.region_rect.size.x
	self.height = $Cover.region_rect.size.y
	self.reset()
	
	if Features.is_enabled("defend action"):
		AdvancedActions["defend"] = 128

func _process(delta):
	if self.state == "first showing":
		# after one second elapses, hide/close again
		var now = OS.get_ticks_msec()
		if now - self.created_on >= _SHOW_TIME_MILLISECONDS:
			self.hide_contents()

func freeze():
	self.state = "done" # disables clicking on 'em

func reset():
	self.state = "first showing"
	self.do_not_change = false
	# Add a random value (in the future) so they pseudo-randomly hide
	# Limit this to 200ms
	self.created_on = OS.get_ticks_msec() + (randi() % 500)
	$Cover.region_rect.position.x = self.frames["open"]
	self._pick_contents()
	self._show_contents()

func refresh_display():
	var target_x = 0
	if self.contents == "energy":
		target_x = ENERGY_X
	elif self.contents in Actions.keys():
		target_x = Actions[self.contents]
	elif self.contens in AdvancedActions:
		target_x = AdvancedActions[self.contents]
	
	$Contents.region_rect.position.x = target_x

func _pick_contents():
	if randf() <= _WRONG_ACTION_PROBABILITY:
		self.contents = "wrong"
		$Contents.region_rect.position.x = WRONG_IMAGE_X
	else:
		self.contents = null
		if self.show_advanced_actions == true:
			# % probability of advanced action
			if randi() % 100 <= _PROBABILITY_OF_ADVANCED_TILE:
				self.contents = self.AdvancedActions.keys()[randi() % AdvancedActions.keys().size()]
				$Contents.region_rect.position.x = self.AdvancedActions[self.contents]
		
		if self.contents == null: # advanced but not picked; or basic choices only
			self.contents = self.Actions.keys()[randi() % self.Actions.keys().size()]
			$Contents.region_rect.position.x = self.Actions[self.contents]
		

func _on_Area2D_input_event(viewport, event, shape_idx):
	if self.state == "closed" and (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		self.state = "open"
		self._show_contents()
		self.emit_signal("tile_selected", self)
		
func _show_contents():
	$Cover.region_rect.position.x = self.frames["open"]
	$Contents.visible = true

func hide_contents():
	$Cover.region_rect.position.x = self.frames["closed"]
	self.state = "closed"
	$Contents.visible = false