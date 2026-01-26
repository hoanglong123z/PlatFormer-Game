extends CharacterBody2D

# -- RUN --#
const SPEED = 100.0
const JUMP_VELOCITY = -250.0

# -- DASH --#
const DASH_SPEED = 200.0
const DASH_TIME = 0.3
const DASH_COOLDOWN = 3.6
var is_dashing = false    
var can_dash = true
var ghost_timer = 0.0
var dash_timer = 0.0
# -- ATTACK --#
const ATTACK_COOLDOWN = 1.0
var damage = 1.0
var is_attacking = false

# -- Heart --#
var hearts_list : Array[TextureRect]
var health = 3 

var is_dying = false
var is_hurt = false
var can_take_damage = true
var is_braking = false #phanh
var is_tunring = false #quay đầu
var last_direction = 0 #lưu biến cũ
@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var attack_area: Area2D = $AttackArea
@onready var dash_bar: TextureProgressBar = $heart_bar/DashBar

func _ready() -> void:
	if GameManager.has_loaded_data():
		global_position = GameManager.get_loaded_position()
		health = GameManager.get_loaded_health() # <--- LẤY MÁU TỪ FILE SAVE
		GameManager.clear_loaded_data() # Xóa dữ liệu tạm sau khi lấy xong
		
		GameManager.respawn_position = global_position
		print("Player đã load game! Máu: ", health)
		
	elif GameManager.respawn_position != Vector2.ZERO:
		global_position = GameManager.respawn_position
		print("Hồi sinh tại Checkpoint cũ: ", GameManager.respawn_position)
	else:
		var start_point = get_parent().get_node_or_null("StartPoint")
		if start_point:
			global_position = start_point.global_position
			GameManager.respawn_position = global_position
	var hearts_parent = $heart_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
		print(hearts_list)
	update_heart_display()

func take_damage(amount = 1) -> bool:
	if is_dashing or not can_take_damage or is_dying:
		print("Đang lướt - Bất tử!")
		return false
	health -= amount
	update_heart_display()
	if health <= 0:
		die()
	else:
		# Gọi hàm xử lý hiệu ứng
		start_hurt_sequence()
	return true
func start_hurt_sequence():
	if is_hurt:
		return
	if is_attacking:
		is_attacking = false
	if is_dashing:
		is_dashing = false
	
	is_hurt = true
	can_take_damage = false # Bất tử tạm thời
	
	animated_sprite.play("hurt")
	print("Á đau quá!")
	
	# Chờ hết animation hurt 
	await get_tree().create_timer(0.4).timeout
	is_hurt = false # Trả lại quyền điều khiển
	
	if not is_dying:
		animated_sprite.play("idle")
	# Chờ thêm xíu nữa mới hết bất tử 
	await get_tree().create_timer(0.6).timeout
	can_take_damage = true
func kill_instant():
	health = 0 
	update_heart_display()
	die()

func die():
	is_dying = true 
	animated_sprite.play("died")
	print("Hẹo rồi!")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()



func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health


func _process(delta: float) -> void:
	if dash_bar:
		if can_dash:
			dash_bar.value = 100
		else:
			var percent = 100 - (dash_timer / DASH_COOLDOWN) * 100
			dash_bar.value = percent
	if not can_dash:
		dash_timer -= delta
		if dash_timer <= 0:
			can_dash = true
			dash_timer = 0
			print("Dash Đã Hồi")


func _physics_process(delta: float) -> void:
	# Dash
	if is_dashing:
		spawn_ghost_trail(delta)
		move_and_slide()
		return
		
	# Attack
	#if is_attacking:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.y += get_gravity().y * delta
		#move_and_slide()
		#return
	
	if is_dying:
		velocity.x = 0
		velocity += get_gravity() * delta
		move_and_slide()
		return

	if is_hurt:
		velocity.x = 0
		velocity += get_gravity() * delta
		move_and_slide()
		return 
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#Xử Lý Attack
	if Input.is_action_just_pressed("Attack"):
		perform_attack()
		return
	
	#Xử lý Dash
	if Input.is_action_just_pressed("Dash") and can_dash:
		start_dash()
		move_and_slide()
		return
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
	#get the input direction : -1 , 0 , 1
	var direction := Input.get_axis("move_left", "move_right")
	#flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
		attack_area.scale.x = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_area.scale.x = -1

	#play animation
	if not is_attacking:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func perform_attack():
	if is_attacking: 
		return
	is_attacking = true
	animated_sprite.play("Attack")
	
	await  get_tree().create_timer(0.1).timeout
	var targets = []
	targets.append_array(attack_area.get_overlapping_bodies())
	targets.append_array(attack_area.get_overlapping_areas())
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage, global_position)
			print("chém trúng: ", target.name)
		elif target.get_parent().has_method("take_damage"):
			target.get_parent().take_damage(damage, global_position)
			print("Chém trúng (qua cha): ", target.get_parent().name)
	#await get_tree().create_timer(0.4).timeout
	await animated_sprite.animation_finished
	
	is_attacking = false
func start_dash():
	can_dash = false
	dash_timer = DASH_COOLDOWN
	is_dashing = true
	set_collision_mask_value(2,false)
	animated_sprite.play("Dash")
	var dash_direction = Input.get_axis("move_left", "move_right")
	if dash_direction == 0:
		if animated_sprite.flip_h == true:
			dash_direction = -1
		else:
			dash_direction = 1

	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0
	
	await get_tree().create_timer(DASH_TIME).timeout
	end_dash()

func end_dash():
	is_dashing = false
	
	set_collision_mask_value(2, true)
	
	velocity.x = 0

func spawn_ghost_trail(delta):
	ghost_timer += delta
	
	if ghost_timer > 0.03:
		ghost_timer = 0
		
		var ghost = Sprite2D.new()
		
		ghost.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
		
		ghost.global_position = animated_sprite.global_position
		ghost.flip_h = animated_sprite.flip_h
		ghost.scale = animated_sprite.scale
		
		ghost.modulate = Color(0.2,1.0,1.0,0.7)
		ghost.z_index = 2
		
		get_parent().add_child(ghost)
		
		var tween = create_tween()
		tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
		tween.tween_callback(ghost.queue_free)
