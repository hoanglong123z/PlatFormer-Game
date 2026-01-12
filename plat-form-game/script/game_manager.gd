extends Node

var score = 0
@onready var score_label = %ScoreLabel
@onready var pause: Control = %Pause
@onready var pausegame: Button = %Pausegame


var respawn_position = Vector2.ZERO
var start_position = Vector2(-182,151)
signal score_updated
func _ready() -> void:
	pass
func add_point():
	score += 1
	if score_label:
		score_label.text = str(score)
	score_updated.emit()
		
func _on_pausegame_pressed() -> void:
	if get_tree().paused:
		pause.resume()
		pausegame.visible = true
	else:
		pause.pause()
		pausegame.visible = false

func reset_game_data():
	print("--- ĐANG RESET DỮ LIỆU ---")
	score = 0 
	respawn_position = start_position
	CheckPoint.last_position = null
