extends Area2D

@export var heal_amount = 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		if body.has_method("heal"):
			if body.health < 3:
				body.heal(heal_amount)
				queue_free()
			else:
				print("Máy đầy, Không ăn được!")
