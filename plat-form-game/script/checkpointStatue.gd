extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("idle")


func _on_body_entered(body: Node2D) -> void:
	CheckPoint.last_position = global_position
	if body.is_in_group("Player"):
		GameManager.respawn_position = global_position
		$AnimatedSprite2D.play("fire")
		$AnimatedSprite2D.position.y = -2.8
