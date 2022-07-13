extends MenuState

var _selected_index := 0
var _input_name_idx := 0
var _input_letter := 0

func _init(_owner).(_owner):
	pass

func get_type() -> int:
	return Globals.MENU_STATE.INPUT_NAME

func enter_state(meta := {}) -> void:
	owner.n_PressStartContainer.visible = false
	owner.n_AnimationPlayer.stop()
	owner.n_PlayerNameInput.visible = true

func input(event) -> void:
	if Input.is_action_just_pressed("ui_left"):
		owner.n_InputNameLabels[_input_name_idx].deselect()
		_input_name_idx = wrapi(_input_name_idx - 1, 0, 3)
		owner.n_InputNameLabels[_input_name_idx].select()
	elif Input.is_action_just_pressed("ui_right"):
		owner.n_InputNameLabels[_input_name_idx].deselect()
		_input_name_idx = wrapi(_input_name_idx + 1, 0, 3)
		owner.n_InputNameLabels[_input_name_idx].select()
	elif Input.is_action_just_pressed("ui_up"):
		owner.n_InputNameLabels[_input_name_idx]._scancode += 1
	elif Input.is_action_just_pressed("ui_down"):
		owner.n_InputNameLabels[_input_name_idx]._scancode -= 1
	elif Input.is_action_just_pressed("ui_accept"):
		owner.set_state(Global.MENU_STATE.GAME_LIST_EXPAND)
