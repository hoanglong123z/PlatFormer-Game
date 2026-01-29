extends Area2D

@export var bonus_damage = 1
@export var duration = 120.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		if body.has_method("boots_damage"):
			body.boots_damage(bonus_damage, duration)
			queue_free()
