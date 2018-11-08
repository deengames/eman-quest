extends WindowDialog

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	self.popup_exclusive = true

func set_text(text):
	$Label.text = text