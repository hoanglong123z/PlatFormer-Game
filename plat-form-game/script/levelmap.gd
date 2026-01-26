extends Control
@onready var lv_1: Button = $Lv1
@onready var lv_2: Button = $Lv2


func _ready() -> void:
	update_level_buttons()

func update_level_buttons():
	var max_lv = GameManager.highest_unlocked_level
	
	if lv_1: 
		lv_1.disabled = false
	if lv_2:
		if max_lv >= 2:
			lv_2.disabled = false
			lv_2.modulate = Color(1,1,1,1)
		else:
			lv_2.disabled = true
			lv_2.modulate = Color(0.5,0.5,0.5,1)
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_lv_1_pressed() -> void:
	GameManager.delete_save() 
	print("Đã bấm nút Level 1")
	GameManager.reset_game_data()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	

func _on_lv_2_pressed() -> void:
	GameManager.delete_save() 
	print("Vào Level 2")
	GameManager.reset_game_data()
	get_tree().change_scene_to_file("res://Scenes/map_2.tscn")
