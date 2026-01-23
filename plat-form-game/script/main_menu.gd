extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options
@onready var continue_btn: Button = $MainButtons/Button4

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false
	if GameManager.has_save_file():
		continue_btn.visible = true
	else:
		continue_btn.visible = false

func _on_start_pressed() -> void:
	GameManager.delete_save() 

	if has_node("/root/CheckPoint"): 
		CheckPoint.last_position = null
	
	get_tree().change_scene_to_file("res://Scenes/levelmap.tscn")


func _on_option_pressed() -> void:
	print("Option pressed")
	main_buttons.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_options_pressed() -> void:
	_ready()


func _on_continue_pressed() -> void:
	GameManager.load_game()
