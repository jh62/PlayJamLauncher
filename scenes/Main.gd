extends Control

enum MENU_STATE {
	INTRO,
	GAME_LIST_EXPAND,
	GAME_SELECTION,
	GAME_EXECUTE
}

onready var n_ItemList := $SidePanelControl/MarginContainer/ItemList
onready var n_WarningDialog := $Control/AcceptDialog
onready var n_AnimationPlayer := $AnimationPlayer

var menu_state = MENU_STATE.INTRO setget set_state

func _ready():
	var _dir_list := _create_game_dir()
	_populate_games(_dir_list)
	
func _create_game_dir() -> Directory:
	var _path
	
	if OS.has_feature("standalone"):
		_path = OS.get_executable_path().get_base_dir() + "/.games"
		print_debug("RELEASE MODE")
	else:
		_path = OS.get_executable_path().get_base_dir() + "/PlayJamLauncher/.games" # test path
		print_debug("DEBUG MODE")
		
	var _dir_list := Directory.new()
	
	if _dir_list.open(_path) != OK:
		_dir_list.make_dir(_path)
		print_debug("No se encontró el directorio de juegos. Será creado.")
		return _create_game_dir()
	
	return _dir_list

func _populate_games(_dir_list : Directory) -> void:
	
	_dir_list.list_dir_begin(true, true)
	var _file  = _dir_list.get_next()
	var _item_idx := 0
	
	while _file != "":
		if _dir_list.current_is_dir():
			continue
		
		n_ItemList.add_item(_file.trim_suffix(".exe"))
		n_ItemList.set_item_metadata(_item_idx, _dir_list.get_current_dir() + "/" + _file)
		
		_file = _dir_list.get_next()
		_item_idx += 1
	
	if n_ItemList.get_item_count() == 0:
		n_WarningDialog.dialog_text = "No se encontraron juegos!"
		n_WarningDialog.show()
		return
	
	n_ItemList.select(0)
		
func _unhandled_key_input(event):
	match menu_state:
		MENU_STATE.INTRO:
			if Input.is_key_pressed(KEY_ENTER):
				set_state(MENU_STATE.GAME_LIST_EXPAND)
		MENU_STATE.GAME_SELECTION:
			if Input.is_key_pressed(KEY_ENTER):
				set_state(MENU_STATE.GAME_EXECUTE)

func set_state(_state : int) -> void:
	menu_state = _state
	
	match _state:
		MENU_STATE.INTRO:
			pass
		MENU_STATE.GAME_LIST_EXPAND:
			n_ItemList.grab_focus()
			n_AnimationPlayer.play("game_list_expand")
			set_state(MENU_STATE.GAME_SELECTION)
		MENU_STATE.GAME_EXECUTE:
			var _item = n_ItemList.get_selected_items()[0]
			var _meta = n_ItemList.get_item_metadata(_item)
			OS.execute(_meta, [], true)
			set_state(MENU_STATE.GAME_SELECTION)

func _on_AcceptDialog_confirmed():
	get_tree().reload_current_scene()
