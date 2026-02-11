extends Area2D

@onready var animation_player = $AnimationPlayer

func _ready():
	# Kiểm tra sổ tử thần: Nếu ID của tao có trong list -> Tự hủy
	var my_id = str(get_path())
	if GameManager.is_object_dead(my_id):
		queue_free()
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.add_point()
		
		# QUAN TRỌNG: Ghi danh vào sổ tử thần (trong RAM)
		# Lưu ý: Lúc này chưa lưu xuống file, chỉ lưu vào RAM.
		# Nếu chết hoặc thoát mà chưa chạm checkpoint -> List này sẽ bị reset khi Load
		GameManager.register_death(str(get_path()))
		
		# Chạy animation ăn vàng rồi queue_free()
		$AnimationPlayer.play("pickup")
