extends Node2D

func _enter_tree() -> void:
	if CheckPoint.last_position:
		$Player	.global_position = CheckPoint.last_position
