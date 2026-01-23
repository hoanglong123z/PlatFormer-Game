extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("idle")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# 1. Update vị trí hồi sinh
		CheckPoint.last_position = global_position
		GameManager.respawn_position = global_position
		
		# 2. Hiệu ứng
		$AnimatedSprite2D.play("fire")
		$AnimatedSprite2D.position.y = -2.8
		
		# 3. GỌI HÀM SAVE NGAY LẬP TỨC
		GameManager.save_game()
		
		print("Đã chạm Checkpoint -> GAME ĐÃ ĐƯỢC LƯU!")
