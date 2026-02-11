extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_mode = DisplayServer.window_get_mode()
	var is_fullscreen = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN)
	if is_fullscreen:
		set_pressed(true) 
	else:
		set_pressed(false) 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
