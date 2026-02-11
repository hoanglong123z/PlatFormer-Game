extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var kill_zone_col = $KillZone/CollisionShape2D

func _ready():
	# Cho lưỡi cưa chạy animation mặc định
	animated_sprite.play("default")

func _process(delta):
	# Lấy số thứ tự của frame hiện tại (0, 1, 2, 3...)
	var frame = animated_sprite.frame
	
	# Xử lý vị trí hitbox dựa theo frame
	match frame:
		0: 
			kill_zone_col.disabled = false
			kill_zone_col.position.x = -17.485
			kill_zone_col.position.y = 0
		1: 
			kill_zone_col.disabled = false
			kill_zone_col.position.x = -10.315
			
		2: 
			kill_zone_col.disabled = false
			kill_zone_col.position.x = 3.875
		3:
			kill_zone_col.disabled = false
			kill_zone_col.position.x = 15.465
		4:
			kill_zone_col.disabled = false
			kill_zone_col.position.x = 3.875
		5:
			# Frame 5: Cưa thụt xuống lại -> Vị trí thấp hoặc tắt luôn
			kill_zone_col.disabled = false
			kill_zone_col.position.x = -10.315
			
		0:
			kill_zone_col.disabled = true
