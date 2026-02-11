extends Label


func _ready():
	# Lấy điểm từ GameManager đập vào mặt luôn
	text = str(GameManager.score)
	# Kết nối lại để cập nhật về sau
	GameManager.score_label = self
