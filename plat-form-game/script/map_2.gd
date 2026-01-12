extends Node
@onready var pause: Control = %Pause
@onready var pausegame: Button = %Pausegame
@onready var score_label: Label = %ScoreLabel

func _enter_tree() -> void:
		if CheckPoint.last_position:
			$Player	.global_position = CheckPoint.last_position
func _ready() -> void:
	if has_node("%ScoreLabel"):
		GameManager.score_label = %ScoreLabel
		GameManager.score_label.text = str(GameManager.score)
	if has_node("%Pause"):
		GameManager.pause = %Pause
	if has_node("%Pausegame"):
		GameManager.pausegame = %Pausegame


func _on_pausegame_pressed() -> void:
	if get_tree().paused:
		pause.resume()
		pausegame.visible = true
	else:
		pause.pause()
		pausegame.visible = false
