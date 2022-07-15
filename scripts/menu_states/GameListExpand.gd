extends MenuState

func _init(_owner).(_owner):
	pass

func get_type() -> int:
	return Globals.MENU_STATE.GAME_LIST_EXPAND

func enter_state(meta := {}) -> void:
	owner.n_AnimationPlayer.connect("animation_finished", self, "_animation_finished")
	
	owner.n_AnimationPlayer.play("game_list_expand")
	owner.update_player_info()

func exit_state() -> void:
	owner.n_AnimationPlayer.disconnect("animation_finished", self, "_animation_finished")

func input(event) -> void:
	pass

func _animation_finished(_anim_name) -> void:
	owner.n_ItemList.grab_focus()
	owner.set_state(Globals.MENU_STATE.GAME_SELECTION)
