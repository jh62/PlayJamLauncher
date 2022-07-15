extends MenuState

enum EXIT_CODES {
	WIN = 1,
	LOSE = 2,
	QUIT = 0
}

var _item_list : ItemList
var _index : int

func _init(_owner).(_owner):
	pass

func get_type() -> int:
	return Globals.MENU_STATE.GAME_EXECUTE

func enter_state(meta := {}) -> void:
	_index = meta.get(Globals.METADATA.GAME_INDEX)
	_item_list = owner.n_ItemList
	
func input(event) -> void:
	pass

func process(delta) -> void:
	var _game_path = _item_list.get_item_metadata(_index)
	var _file = _game_path[Global.GAME_METADATA.PATH] + "/" + _game_path[Global.GAME_METADATA.FILENAME]
	print_debug("Ejecutando: {0}".format({0:_game_path}))
	var score_start := OS.get_ticks_msec()
	
	var _exit_code
	
	if Globals.debug_mode:
		_exit_code = EXIT_CODES.LOSE
		print_debug("exit code: " + str(_exit_code))
	else:
		_exit_code = OS.execute(_file, [], true)
		
	yield(owner.get_tree().create_timer(randf()),"timeout")
		
	var score_end := OS.get_ticks_msec() - score_start
		
	match _exit_code:
		EXIT_CODES.WIN:
			score_end *= 1.25
		EXIT_CODES.LOSE:
			Globals.emit_signal("player_lost_life")
		EXIT_CODES.QUIT:
			owner.set_state(Globals.MENU_STATE.GAME_SELECTION)
			print_debug("El juego fue cancelado.")
			return
		
	_index = wrapi(_index + 1, 0, _item_list.get_item_count())
	
	Globals.emit_signal("update_player_scores", score_end)
	
