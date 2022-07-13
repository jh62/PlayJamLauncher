class_name Main extends Control

const CONFIG_FILENAME := "config.cfg"

onready var n_ItemList := $MarginContainer/SidePanelControl/MarginContainer/ItemList
onready var n_AnimationPlayer := $AnimationPlayer
onready var n_ThumbnailTexture := $GameThumbnail
onready var n_PressStartContainer := $PressStartContainer
onready var n_LabelPlayerName := $PlayerDataContainer/VBoxContainer/LabelPlayerName
onready var n_LabelPlayerLives := $PlayerDataContainer/VBoxContainer/LabelPlayerLives
onready var n_InputNameLabels := [
	$CanvasLayer/Control/CCPlayerName/VBox/CC/GC/LetterInput1,
	$CanvasLayer/Control/CCPlayerName/VBox/CC/GC/LetterInput2,
	$CanvasLayer/Control/CCPlayerName/VBox/CC/GC/LetterInput3
]
onready var n_WarningDialog := $CanvasLayer/Control/PopUpControl/AcceptDialog
onready var n_PlayerNameInput := $CanvasLayer/Control/CCPlayerName

onready var MenuStates := {
	Global.MENU_STATE.INTRO: preload("res://scripts/menu_states/IntroState.gd").new(self),
	Global.MENU_STATE.INPUT_NAME: preload("res://scripts/menu_states/InputNameState.gd").new(self),
	Global.MENU_STATE.GAME_LIST_EXPAND: preload("res://scripts/menu_states/GameListExpand.gd").new(self),
	Global.MENU_STATE.GAME_SELECTION: preload("res://scripts/menu_states/GameSelectionState.gd").new(self),
	Global.MENU_STATE.GAME_EXECUTE: preload("res://scripts/menu_states/GameExecute.gd").new(self),
}

onready var current_state = MenuStates.get(Global.MENU_STATE.INTRO)

var config := ConfigFile.new()
var player_lives := 3 setget set_player_lives

func _ready():
	var _err = config.load(CONFIG_FILENAME)
	
	if _err != OK:
		config.set_value("PlayMode", "play_mode", Global.PLAY_MODE.SEAMLESS)
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
			
		if !(_file.ends_with("exe")):
			_file = _dir.get_next()
			continue
			
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
			Global.GAME_METADATA.PATH: _subpath,
			Global.GAME_METADATA.FILENAME: _file
		})
		
		_file = _dir_list.get_next()
		_item_idx += 1
			
	if n_ItemList.get_item_count() == 0:
		n_WarningDialog.dialog_text = "No se encontraron juegos!"
		n_WarningDialog.visible = true
		n_WarningDialog.popup_centered()
		return
	
	n_ItemList.select(0)

func _process(delta):
	current_state.process(delta)
	
func _input(event : InputEvent):
	current_state.input(event)

func set_state(_new_state : int, args := {}) -> void:
	if current_state != null:
		current_state.exit_state()
	
	current_state = MenuStates.get(_new_state)
	current_state.enter_state(args)

func _on_AcceptDialog_confirmed():
	get_tree().reload_current_scene()

func _on_ItemList_item_selected(index):
	pass
	
func set_player_lives(_value) -> void:
	player_lives = clamp(_value, 0, Global.MAX_PLAYER_LIVES)
	update_player_lives()
	
func set_player_score(_new_score) -> void:
	pass
	
func update_player_lives() -> void:
	n_LabelPlayerLives.text = "VIDAS: {0}".format({0:String(player_lives)})

func update_player_name() -> void:
	var _name = n_InputNameLabels[0].get_text() + n_InputNameLabels[1].get_text() + n_InputNameLabels[2].get_text()
	n_LabelPlayerName.text = _name
	
