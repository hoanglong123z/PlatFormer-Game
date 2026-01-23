extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_lv_1_pressed() -> void:
	print("Đã bấm nút Level 1")
	GameManager.reset_game_data()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	

func _on_lv_2_pressed() -> void:
	GameManager.reset_game_data()
	get_tree().change_scene_to_file("res://Scenes/map_2.tscn")
