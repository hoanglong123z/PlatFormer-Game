extends Area2D


@onready var color_rect: ColorRect = $"../../CanvasLayer2/ColorRect"
@onready var label: Label = $"../../CanvasLayer2/Label"


func _ready() -> void:
	# Ẩn tất cả lúc đầu game
	if label:
		label.modulate.a = 0
		label.hide()
	if color_rect:
		color_rect.modulate.a = 0
		color_rect.hide()
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		print("Rơi xuống Vực -> Màn hình tối + Game Over")
		
		# 1. Giết nhân vật
		if body.has_method("kill_instant"):
			body.kill_instant()
		
		# 2. Bắt đầu chuỗi hiệu ứng (Dùng Tween song song)
		if label and color_rect:
			color_rect.show()
			label.show()
			label.text = "Game Over BRUHH" # Nội dung chốt hạ
			
			var tween = create_tween()
			
			# Set cho 2 cái chạy song song
			tween.set_parallel(true) 
			tween.tween_property(color_rect, "modulate:a", 1.0, 0.5) 
			tween.tween_property(label, "modulate:a", 1.0, 0.8)      
			# Sau khi hiện xong thì chờ 1 lúc
			tween.chain().tween_interval(1.5) # Chờ 1.5 giây để người chơi ngắm chữ Game Over

			# Gọi hàm reload khi xong xuôi
			tween.tween_callback(reload_game)

func reload_game():
	GameManager.reset_game_data()
	get_tree().reload_current_scene()
