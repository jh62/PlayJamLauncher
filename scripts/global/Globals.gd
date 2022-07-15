class_name Global extends Node

# signals
signal update_player_scores(score)
signal player_lost_life

const CONFIG_FILENAME := "config.cfg"

const MIN_CHAR_SCANCODE := 65
const MAX_CHAR_SCANCODE := 91

var debug_mode := false

var max_player_lives := 1
var play_mode = PLAY_MODE.SEAMLESS

var current_player : PlayerScore

enum METADATA {
	PLAYER_ID,
	GAME_INDEX
}

enum PLAY_MODE {
	SEAMLESS,
	SINGLE,
	RANDOM
}

enum GAME_METADATA {
	PATH,
	FILENAME
}

enum MENU_STATE {
	INTRO,
	INPUT_NAME,
	GAME_LIST_EXPAND,
	GAME_SELECTION,
	GAME_EXECUTE
}

class ScoreSorter:
	static func sort_ascending(a, b):
		if a.record > b.record:
			return true
		return false
