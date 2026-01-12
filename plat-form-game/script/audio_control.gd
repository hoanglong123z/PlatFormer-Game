extends HSlider

const MUSIC_BUS_NAME = "Music"

var music_bus_id
func _ready() -> void:
	music_bus_id = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if music_bus_id != -1:
		var current_db = AudioServer.get_bus_volume_db(music_bus_id)
		value = db_to_linear(current_db)
	self.connect("value_changed", _on_value_changed)
	
func _on_value_changed(value: float) -> void:
	music_bus_id = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if music_bus_id != -1:
		var db = linear_to_db(value)
		AudioServer.set_bus_volume_db(music_bus_id , db)
