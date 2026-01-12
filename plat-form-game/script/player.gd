extends CharacterBody2D

# -- RUN --#
const SPEED = 100.0
const JUMP_VELOCITY = -250.0

# -- DASH --#
const DASH_SPEED = 200.0
const DASH_TIME = 0.3
const DASH_COOLDOWN = 1.0
var is_dashing = false    
var can_dash = true
var ghost_timer = 0.0
var dash_timer = 0.0
# -- ATTACK --#
const ATTACK_COOLDOWN = 0.5
var damage = 1
var is_attacking = false

# -- Heart --#
var hearts_list : Array[TextureRect]
var health = 3 

var is_dying = false
var can_take_damage = true
@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
@onready var attack_area: Area2D = $AttackArea
@onready var dash_bar: TextureProgressBar = $heart_bar/DashBar

func _ready() -> void:
	if GameManager.respawn_position == Vector2.ZERO:
		var start_point = get_parent().get_node_or_null("StartPoint")
		if start_point:
			global_position = start_point.global_position
			GameManager.respawn_position = global_position
			CheckPoint.last_position = null
			print("Game mới! Đã cưỡng chế về StartPoint: ", global_position)
		else:
			print("LỖI: Quên chưa tạo StartPoint trong Map rồi bro ơi!")
	else:
		global_position = GameManager.respawn_position
		print("Game cũ! Hồi sinh tại checkpoint: ", GameManager.respawn_position)
	
	var hearts_parent = $heart_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print(hearts_list)

func take_damage(amount = 1) -> bool:
	if is_dashing or not can_take_damage:
		print("Đang lướt - Bất tử!")
		return false
	if health > 0:
		health -= amount
		update_heart_display()
		can_take_damage = false
		get_tree().create_timer(1.0).timeout.connect(func(): can_take_damage = true)
		return true
	return true
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
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return
	# Add the gravity.
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
		animated_sprite.position.x = 5
		attack_area.scale.x = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		animated_sprite.position.x = -7
		attack_area.scale.x = -1
	#play animation
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
	is_attacking = true
	
	animated_sprite.play("Attack")
	await  get_tree().create_timer(0.1).timeout
	var targets = []
	targets.append_array(attack_area.get_overlapping_bodies())
	targets.append_array(attack_area.get_overlapping_areas())
	
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage)
			print("chém trúng: ", target.name)
		elif target.get_parent().has_method("take_damage"):
			target.get_parent().take_damage(damage)
			print("Chém trúng (qua cha): ", target.get_parent().name)
	#var bodies = attack_area.get_overlapping_bodies()
	#for body in bodies:
		#if body.has_method("take_damage"):
			#body.take_damage(damage)
			#print("Đã chém trúng: ", body.name)
	await get_tree().create_timer(0.3).timeout
	
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
