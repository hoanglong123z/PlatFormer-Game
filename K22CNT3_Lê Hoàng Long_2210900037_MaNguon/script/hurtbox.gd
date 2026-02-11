extends Area2D

func take_damage(amount, source_pos = Vector2.ZERO):
	if get_parent().has_method("take_damage"):
		get_parent().take_damage(amount, source_pos)
		print("Hurtbox nhận đòn từ: ", source_pos)
