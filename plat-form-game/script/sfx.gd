extends HSlider


const SFX_BUS_NAME = "SFX"
var sfx_bus_idx
func _ready() -> void:
	sfx_bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	if sfx_bus_idx != -1:
		var current_db = AudioServer.get_bus_volume_db(sfx_bus_idx)
		value = db_to_linear(current_db)
	self.connect("value_changed", _on_value_changed)
	
func _on_value_changed(value: float) -> void:
	sfx_bus_idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	if sfx_bus_idx != -1:
		var db = linear_to_db(value)
		AudioServer.set_bus_volume_db(sfx_bus_idx , db)
