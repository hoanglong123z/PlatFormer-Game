extends CharacterBody2D

@export var aim_offset = Vector2(0, -15)
# --- CẤU HÌNH ---
@export var speed = 40.0
@export var health = 20
@export var damage = 1
@export var rocket_scene: PackedScene 
@export var laser_scene: PackedScene

# --- BIẾN ---
var direction = 1 
var player = null 
var can_attack = true

enum {IDLE, CHASE, ATTACK_ARM, ATTACK_LASER, DIE, STUN}
var state = IDLE

# --- NODES ---
@onready var sprite = $AnimatedSprite2D
@onready var muzzle_arm = $MuzzleArm
@onready var muzzle_laser = $MuzzleLaser
@onready var raycast = $RayCast2D # Nhớ bật Enabled trong Inspector nhé!

func _ready():
	if GameManager.is_object_dead(str(get_path())):
		queue_free()
		return
	sprite.play("idle")

func _physics_process(delta):
	if state == DIE: return
	
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# === LOGIC RAYCAST MỚI: LUÔN NHÌN THEO PLAYER ===
	if player:
		# Lấy vị trí chân + dịch lên ngực
		var target_pos = player.global_position + aim_offset
		
		# Chuyển đổi sang toạ độ local để RayCast hiểu
		raycast.target_position = to_local(target_pos)
		raycast.force_raycast_update()

	match state:
		IDLE:
			velocity.x = 0
			sprite.play("idle")
			
		CHASE:
			if player:
				move_towards_player()
				choose_attack()
			else:
				state = IDLE

	move_and_slide()

func move_towards_player():
	if not player: return
	var dir_to_player = global_position.direction_to(player.global_position).x
	
	if dir_to_player > 0: 
		direction = 1
		sprite.flip_h = false 
		# Đưa súng về đúng bên phải
		if muzzle_arm.position.x < 0: muzzle_arm.position.x *= -1
		if muzzle_laser.position.x < 0: muzzle_laser.position.x *= -1
	else: 
		direction = -1
		sprite.flip_h = true 
		# Đưa súng về đúng bên trái
		if muzzle_arm.position.x > 0: muzzle_arm.position.x *= -1
		if muzzle_laser.position.x > 0: muzzle_laser.position.x *= -1

	velocity.x = direction * speed
	sprite.play("walk")

func choose_attack():
	if not can_attack or not player: return
	
	# CHECK RAYCAST: NẾU BỊ TƯỜNG CHẮN THÌ KHÔNG BẮN 
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		# Nếu cái nó nhìn thấy KHÔNG phải là Player Thì thôi nghỉ bắn
		if not collider.is_in_group("Player"):
			return 

	var distance = global_position.distance_to(player.global_position)
	
	if distance < 200: # Tầm gần bắn tay
		state = ATTACK_ARM
		perform_rocket_attack()
	elif distance >= 200 and distance < 500: # Tầm xa bắn laser
		state = ATTACK_LASER
		perform_laser_attack()

# --- BẮN TAY (CÓ NGẮM) ---
func perform_rocket_attack():
	state = ATTACK_ARM
	can_attack = false
	velocity.x = 0 
	if sprite.sprite_frames.has_animation("attack"): 
		sprite.play("attack")
	
	await get_tree().create_timer(0.5).timeout
	
	if rocket_scene and player:
		var rocket = rocket_scene.instantiate()
		get_parent().add_child(rocket)
		rocket.global_position = muzzle_arm.global_position
		
		# === TÍNH HƯỚNG BẮN VÀO PLAYER ===
		var target_pos = player.global_position + aim_offset
		var aim_direction = (player.global_position - muzzle_arm.global_position).normalized()
		rocket.direction = aim_direction # Gán hướng chéo cho đạn
	
	await get_tree().create_timer(1.0).timeout 
	if state != DIE: state = CHASE 
	
	var cooldown_timer = get_tree().create_timer(2.0)
	cooldown_timer.timeout.connect(func(): can_attack = true)


# --- BẮN LASER (CÓ NGẮM) ---
func perform_laser_attack():
	state = ATTACK_LASER
	can_attack = false
	velocity.x = 0
	if sprite.sprite_frames.has_animation("laser"): sprite.play("laser")
	
	await get_tree().create_timer(0.5).timeout
	
	if laser_scene and player:
		var laser = laser_scene.instantiate()
		muzzle_laser.add_child(laser)
		laser.position = Vector2.ZERO
		
		# === TÍNH HƯỚNG BẮN VÀO PLAYER ===
		var target_pos = player.global_position + aim_offset
		laser.look_at(target_pos)
		laser.scale = Vector2(1,1)
		
	await get_tree().create_timer(4.0).timeout
	if state != DIE: state = CHASE
	
	var cooldown_timer = get_tree().create_timer(3.0)
	cooldown_timer.timeout.connect(func(): can_attack = true)

# --- GIỮ NGUYÊN PHẦN DƯỚI (Die, Take Damage, Signals...) ---
func take_damage(amount, source_pos = Vector2.ZERO):
	if state == DIE: return
	health -= amount
	var tween = create_tween()
	sprite.modulate = Color(10, 0, 0)
	tween.tween_property(sprite, "modulate", Color(1,1,1), 0.1)
	if health <= 0: 
		die()
	else:
		# 4. GỌI HÀM STUN
		apply_stun()

func apply_stun():
	state = STUN
	velocity.x = 0
	await get_tree().create_timer(1.0).timeout
	if state != DIE and state == STUN:
		if player:
			state = CHASE
		else:
			state = IDLE
func die():
	GameManager.golem_defeated = true 
	GameManager.save_game()
	if has_node("KillZone"): $KillZone.queue_free()
	GameManager.register_death(str(get_path()))
	if sprite.sprite_frames.has_animation("die"): await sprite.animation_finished
	else: await get_tree().create_timer(1.0).timeout
	queue_free()
	state = DIE
	velocity.x = 0
	sprite.play("die")

func _on_player_detection_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		state = CHASE 

func _on_player_detection_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		state = IDLE
