extends Area2D

func take_damage(amount):
	if get_parent().has_method("take_damage"):
		get_parent().take_damage(amount)
		print("Hurtbox đã nhận đòn -> Truyền cho Quái")
	else:
		print("Trượt rồi kìa má non vãi !")
