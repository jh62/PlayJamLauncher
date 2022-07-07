extends MenuState

func _init(_owner).(_owner):
	pass

func get_type() -> int:
	return Globals.MENU_STATE.INTRO

func input(event) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		owner.set_state(Globals.MENU_STATE.INPUT_NAME)
