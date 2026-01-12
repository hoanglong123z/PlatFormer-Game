extends Control
@onready var pausegame: Button = %Pausegame

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	visible = false
func pause():
	visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func reusume():
	get_tree().paused = false
	pausegame.visible = true
	$AnimationPlayer.play_backwards("blur")
	
	await $AnimationPlayer.animation_finished
	visible = false

func testEsc():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
		pausegame.visible = false
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		reusume()
		pausegame.visible = true

func _on_back_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_back_game_pressed() -> void:
	reusume()
	
func _process(delta: float) -> void:
	testEsc()
