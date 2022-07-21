extends MenuState

var _anim_p : AnimationPlayer

func _init(_owner).(_owner):
	pass

func get_type() -> int:
	return Globals.MENU_STATE.GAME_LOSE

func enter_state(meta := {}) -> void:
	var _anim_p = owner.n_AnimationPlayer
	_anim_p.connect("animation_finished", self, "_on_animation_finished")
	_anim_p.play("lose_life")

func exit_state() -> void:
	_anim_p.disconnect("animation_finished", self, "_on_animation_finished")
	
func input(event) -> void:
	pass

func process(delta) -> void:
	pass

func _on_animation_finished(anim_name : String) -> void:
	pass	
