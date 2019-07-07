extends Node2D

const _PADDING = 8

var title = "" setget set_title, get_title

# It's magic. You add it to a popup window, and it resizes automatically. Closing
# it (click the X button) also closes the underlying popup. Note that it occupes
# the top 58 pixels of the parent, because positioning above the parent (at least,
# with popup instances) causes the click handlers on child controls to just not fire.
func _ready():
	var parent = get_parent()
	
	if "margin_right" in parent:
		$Panel.margin_right = parent.margin_right
	elif "width" in parent:
		$Panel.margin_right = parent.width
	
	var button = $Panel/XButton
	var _BUTTON_SIZE = button.margin_right - button.margin_left
	# move button to RHS
	button.margin_right = $Panel.margin_right
	button.margin_left = $Panel.margin_right - _BUTTON_SIZE
	$Panel/Title.margin_left = _PADDING
	$Panel/Title.margin_right = button.margin_right - _PADDING

func set_title(title):
	$Panel/Title.text = title.to_upper()

func get_title():
	return $Panel/Title.text

func _on_Button_pressed(event):
	if (event is InputEventMouseButton and event.pressed) or (OS.has_feature("Android") and event is InputEventMouseMotion):
		$AudioStreamPlayer.play()
		# Yield for the audio play-time
		yield(get_tree().create_timer(0.2), 'timeout')
		
		var parent = get_parent()
		parent.remove_child(self)
		if parent is Popup:
			parent.emit_signal("popup_hide")
		
		var grandparent = parent.get_parent()
		if grandparent != null:
			grandparent.remove_child(parent)