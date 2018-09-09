extends Node2D

const SHOW_TIME_MILLISECONDS = 1500 # 1000 = 1s
const WRONG_ACTION_PROBABILITY = 0.5 # 0.5 = 50%
signal tile_selected

var created_on = 0

var contents = ""
var state = ""
var width = 0
var height = 0

var tile_x = 0
var tile_y = 0

var show_advanced_actions = false

# open/close x coordinates
var frames = {
	"closed": 0,
	"open": 64
}

const Actions = {
	"attack": 0,
	"critical": 64,
	"defend": 128
}

const AdvancedActions = {
	"heal": 192,
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

func _process(delta):
	if self.state == "first showing":
		# after one second elapses, hide/close again
		var now = OS.get_ticks_msec()
		if now - self.created_on >= SHOW_TIME_MILLISECONDS:
			self.hide_contents()

func freeze():
	self.state = "done" # disables clicking on 'em

func reset():
	self.state = "first showing"
	# Add a random value (in the future) so they pseudo-randomly hide
	# Limit this to 200ms
	self.created_on = OS.get_ticks_msec() + (randi() % 200)
	$Cover.region_rect.position.x = self.frames["open"]
	self._pick_contents()
	self._show_contents()
	
func _pick_contents():
	if randf() <= WRONG_ACTION_PROBABILITY:
		self.contents = "wrong"
		$Contents.region_rect.position.x = WRONG_IMAGE_X
	else:
		self.contents = null
		if self.show_advanced_actions == true:
			# % probability of advanced action
			if randi() % 100 <= 25:
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