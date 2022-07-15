class_name PlayerScore extends GridContainer

var record := 0 setget set_record

func get_player_id() -> int:
	return get_index()
	
func equals() -> void:
	pass

func get_name() -> String:
	return $LabelName.text

func set_name(_name : String) -> void:
	$LabelName.text = _name.to_upper().substr(0,3)

func set_record(_value) -> void:
	record = _value
	$LabelRecord.text = String(_value)
