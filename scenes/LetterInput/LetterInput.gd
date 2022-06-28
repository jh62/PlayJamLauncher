extends VBoxContainer

const MIN_CHAR_SCANCODE := 65
const MAX_CHAR_SCANCODE := 91

onready var n_Label := $Label
onready var n_LabelUnderscore := $LabelUnderscore
onready var n_Tween := $Tween

var _scancode := 0 setget set_scancode

func select() -> void:
	_fade_in()

func deselect() -> void:
	n_LabelUnderscore.modulate.a = 1.0
	n_Tween.stop_all()

func set_letter(_letter : int) -> void:
	n_Label.text = OS.get_scancode_string(_letter)
	
func set_scancode(_val) -> void:
	_scancode = wrapi(_val, MIN_CHAR_SCANCODE, MAX_CHAR_SCANCODE)
	set_letter(_scancode)

func _fade_out() -> void:
	n_Tween.interpolate_property(n_LabelUnderscore, "modulate", Color(1.0,1.0,1.0,1.0), Color(1.0,1.0,1.0,0.0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	n_Tween.start()

func _fade_in() -> void:
	n_Tween.interpolate_property(n_LabelUnderscore, "modulate", Color(1.0,1.0,1.0,0.0), Color(1.0,1.0,1.0,1.0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)	
	n_Tween.start()
	
func _on_Tween_tween_completed(object, key):
	if n_LabelUnderscore.modulate.a == 0.0:
		_fade_in()
	else:
		_fade_out()
