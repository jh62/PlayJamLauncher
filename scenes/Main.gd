extends Control

const CONFIG_FILENAME := "config.cfg"

enum MENU_STATE {
	INTRO,
	GAME_LIST_EXPAND,
	GAME_SELECTION,
	GAME_EXECUTE
}

onready var n_ItemList := $SidePanelControl/MarginContainer/ItemList
onready var n_WarningDialog := $CanvasLayer/PopUpControl/AcceptDialog
onready var n_AnimationPlayer := $AnimationPlayer
onready var n_ThumbnailTexture := $GameThumbnail

var config := ConfigFile.new()

var menu_state = MENU_STATE.INTRO setget set_state

func _ready():
	var _err = config.load(CONFIG_FILENAME)
	
	if _err != OK:
		config.set_value("PlayMode", "play_mode", Enums.PLAY_MODE.SEAMLESS)
		save_settings()
		
	var _dir_list := _create_game_dir()
	_populate_games(_dir_list)

func save_settings() -> void:
	config.save("config.cfg")
	
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

func find_game(_path):
	
	var _dir := Directory.new()
	_dir.open(_path)
	_dir.list_dir_begin(true, true)
	var _file  := _dir.get_next()
	
	while _file != "":
		if _dir.current_is_dir():
			_file = find_game(_dir.get_current_dir() + "/" + _file)
		if !_file.ends_with(".exe"):
			_file = _dir.get_next()
		break
	
	_dir.list_dir_end()
	return _file

func _populate_games(_dir_list : Directory) -> void:
	_dir_list.list_dir_begin(true, true)
	var _file  = _dir_list.get_next()
	var _item_idx := 0
	
	while _file != "":
		var _subpath = _dir_list.get_current_dir() + "/" + _file
		
		if _dir_list.current_is_dir():
			_file = find_game(_subpath)
		
		n_ItemList.add_item(_file.trim_suffix(".exe"))
		n_ItemList.set_item_metadata(_item_idx, {
			Enums.GAME_METADATA.PATH: _subpath,
			Enums.GAME_METADATA.FILENAME: _file
		})
		
		_file = _dir_list.get_next()
		_item_idx += 1
			
	if n_ItemList.get_item_count() == 0:
		n_WarningDialog.dialog_text = "No se encontraron juegos!"
		n_WarningDialog.visible = true
		n_WarningDialog.popup_centered()
		return
	
	n_ItemList.select(0)

var _selected_index := 0

func _input(event : InputEvent):
	match menu_state:
		MENU_STATE.INTRO:
			if Input.is_key_pressed(KEY_ENTER):
				set_state(MENU_STATE.GAME_LIST_EXPAND)
		MENU_STATE.GAME_SELECTION:
			if n_ItemList.get_item_count() == 0:
				return
				
			if Input.is_action_pressed("ui_up"):
				_selected_index = max(_selected_index - 1, 0)
			elif Input.is_action_pressed("ui_down"):
				_selected_index = min(_selected_index + 1, n_ItemList.get_item_count() - 1)				
			
			n_ItemList.select(_selected_index)
			
			var _meta = n_ItemList.get_item_metadata(_selected_index)
			var _thumbnail_path = _meta[Enums.GAME_METADATA.PATH] + "/thumb.png"
			var image := Image.new()
			image.load(_thumbnail_path)
			var t := ImageTexture.new()
			t.create_from_image(image)
			n_ThumbnailTexture.texture = t
				
			if Input.is_key_pressed(KEY_ENTER):
				set_state(MENU_STATE.GAME_EXECUTE)

func set_state(_state : int) -> void:
	menu_state = _state
	
	match _state:
		MENU_STATE.INTRO:
			pass
		MENU_STATE.GAME_LIST_EXPAND:
			n_AnimationPlayer.play("game_list_expand")
			set_state(MENU_STATE.GAME_SELECTION)
			n_ItemList.grab_focus()
		MENU_STATE.GAME_EXECUTE:
			for i in n_ItemList.get_item_count():
				var _game_path = n_ItemList.get_item_metadata(i)
				var _file = _game_path[Enums.GAME_METADATA.PATH] + "/" + _game_path[Enums.GAME_METADATA.FILENAME]
				print_debug("Executing: {0}".format({0:_game_path}))
				OS.execute(_file, [], true)
			
			set_state(MENU_STATE.GAME_SELECTION)

func _on_AcceptDialog_confirmed():
	get_tree().reload_current_scene()

func _on_ItemList_item_selected(index):
	_selected_index = index
