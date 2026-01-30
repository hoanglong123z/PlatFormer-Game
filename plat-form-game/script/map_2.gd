extends Node
@onready var pause: Control = %Pause
@onready var pausegame: Button = %Pausegame
@onready var score_label: Label = %ScoreLabel
@onready var player: CharacterBody2D = $"../Player"
@onready var start_point: Marker2D = $"../StartPoint"

var start_position = Vector2(-182,151)
var respawn_position = Vector2.ZERO

func _enter_tree() -> void:
		if CheckPoint.last_position:
			$Player	.global_position = CheckPoint.last_position
func _ready() -> void:
	if score_label:
		GameManager.score_label = score_label
		score_label.text = str(GameManager.score)
	if pause:
		GameManager.pause = pause
	if pausegame:
		GameManager.pausegame = pausegame
	
	if start_point:
		GameManager.start_position = start_point.global_position
	else:
		GameManager.start_position = player.global_position
	
	if GameManager.has_loaded_data():
		pass
	elif  CheckPoint.last_position == null:
		GameManager.respawn_position = GameManager.start_position


func _on_pausegame_pressed() -> void:
	if get_tree().paused:
		pause.resume()
		pausegame.visible = true
	else:
		pause.pause()
		pausegame.visible = false
