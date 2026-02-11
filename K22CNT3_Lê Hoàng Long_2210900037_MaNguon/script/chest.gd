extends StaticBody2D

@export var coin_scene: PackedScene
@export var coin_amount = 5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var interaction_area: Area2D = $InteractionArea
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var player_in_range = false
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("idle")
	label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and not is_open:
		if Input.is_action_just_pressed("interact"):
			open_chest()

func open_chest():
	is_open = true
	label.hide()
	collision_shape_2d.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(point_light_2d, "energy", 0.0, 0.5)
	animated_sprite_2d.play("open")
	spawn_coins()

func spawn_coins():
	# 1. DEBUG: Kiểm tra ngay xem có scene chưa
	if coin_scene == null: 
		print("LỖI CỰC MẠNH: Rương tại vị trí ", global_position, " bị mất file Coin!")
		return
	
	var space_state = get_world_2d().direct_space_state
	
	for i in range(coin_amount):
		var coin = coin_scene.instantiate()
		
		# --- FIX 1: Dùng add_child trực tiếp để chỉnh vị trí được ngay ---
		get_parent().add_child(coin)
		
		var start_pos = spawn_point.global_position
		coin.global_position = start_pos
		
		# --- FIX 2: Tính toán vị trí rơi an toàn ---
		var rand_x = randf_range(-40, 40)
		var target_x = start_pos.x + rand_x
		# Rơi xuống thấp hơn vị trí spawn 30px (để chạm đất)
		var target_y = start_pos.y + 0
		
		# --- FIX 3: Bắn tia Raycast check tường (Chống vàng chui vào tường) ---
		var query = PhysicsRayQueryParameters2D.create(start_pos, Vector2(target_x, start_pos.y))
		query.collision_mask = 1 # Chỉ check va chạm với Tường (Layer 1)
		
		var result = space_state.intersect_ray(query)
		if result:
			# Nếu vướng tường -> Rơi ngay trước mặt tường (lùi lại 10px)
			target_x = result.position.x - (10 * sign(rand_x))
			print("Vàng định chui tường -> Đã kéo lại!")

		# Set Z-Index cao lên để không bị rương che mất
		coin.z_index = 10 
		
		# --- TWEEN DI CHUYỂN ---
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Bay ngang
		tween.tween_property(coin, "global_position:x", target_x, 0.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Nhảy lên rơi xuống (Parabol)
		var jump_height = randf_range(-80, -120)
		var jump_tween = create_tween()
		jump_tween.tween_property(coin, "global_position:y", start_pos.y + jump_height, 0.25)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		jump_tween.tween_property(coin, "global_position:y", target_y, 0.25)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		await get_tree().create_timer(0.1).timeout

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		if not is_open:
			label.show()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		label.hide()
