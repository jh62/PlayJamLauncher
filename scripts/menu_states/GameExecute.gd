extends MenuState

enum EXIT_CODES {
	WIN = 1,
	LOSE = 2,
	QUIT = 0
}

var _item_list : ItemList
var _index

func _init(_owner).(_owner):
	pass

func get_type() -> int:
	return Globals.MENU_STATE.GAME_EXECUTE

func enter_state(args = null) -> void:
	_index = args
	_item_list = owner.n_ItemList
	
func input(event) -> void:
	pass

func process(delta) -> void:
	var _game_path = _item_list.get_item_metadata(_index)
	var _file = _game_path[Global.GAME_METADATA.PATH] + "/" + _game_path[Global.GAME_METADATA.FILENAME]
	print_debug("Executing: {0}".format({0:_game_path}))
	var _exit_code := OS.execute(_file, [], true)

	match _exit_code:
		EXIT_CODES.WIN:
			pass
		EXIT_CODES.LOSE:
			owner.player_lives -= 1
		EXIT_CODES.QUIT:
			owner.set_state(Globals.MENU_STATE.GAME_SELECTION)
			return
		
	_index = wrapi(_index + 1, 0, _item_list.get_item_count())
