extends CharacterBody2D

var speed = 60
var player = null 
var is_attacking = false 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var health = 5
var is_dying = false   
var is_taking_damage = false

var player_in_attack_range = false  
var can_attack = true              
var attack_cooldown_time = 0.5
@onready var animated_sprite_2d: AnimatedSprite2D = $Flipper/AnimatedSprite2D
@onready var kill_zone_col: CollisionPolygon2D = $Flipper/KillZone/CollisionPolygon2D
@onready var flipper: Node2D = $Flipper

@export_category("Drop Items")
@export var health_item_scene: PackedScene
@export var damage_item_scene: PackedScene
@export var drop_chance = 0.5
func _ready() -> void:
	var my_id = str(get_path())
	if GameManager.is_object_dead(my_id):
		queue_free()
		return
	kill_zone_col.disabled = true
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_dying or is_taking_damage:
		velocity.x = 0
		move_and_slide()
		return
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	if player_in_attack_range and can_attack:
		attack()
		return
	
	if player:
		var direction = 0
		if player.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
		
		velocity.x = direction * speed

		if direction > 0:
			flipper.scale.x = 1
		elif direction < 0:
			flipper.scale.x = -1
			
		animated_sprite_2d.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite_2d.play("idle")
		
	move_and_slide()

func take_damage(amount, source_pos = Vector2.ZERO):
	if is_dying or is_taking_damage:
		return
	health -= amount
	print("Skeleton bị đánh! Máu còn : ", health)

	if health > 0:
		if is_attacking:
			is_attacking = false
			kill_zone_col.set_deferred("disabled", true)
			
			var cooldown_fix = get_tree().create_timer(1.0) # Thời gian chờ hồi chiêu (1 giây)
			cooldown_fix.timeout.connect(func(): can_attack = true)
			
		is_taking_damage = true
		velocity = Vector2.ZERO
		
		animated_sprite_2d.play("hurt")
		
		if source_pos != Vector2.ZERO:
			if source_pos.x < global_position.x: flipper.scale.x = 1  # Người bên trái -> Quay phải
			else: flipper.scale.x = -1 # Người bên phải -> Quay trái

		var knockback_tween = create_tween()
		var push_dir = 0
		if source_pos != Vector2.ZERO:
			if source_pos.x < global_position.x: push_dir = 1 
			else: push_dir = -1 
		
		var target_pos = global_position.x + (push_dir * 30)
		knockback_tween.tween_property(self, "global_position:x", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		knockback_tween.tween_callback(func(): is_taking_damage = false)
		
	else:
		die()

func die():
	is_dying = true
	is_taking_damage = true
	is_attacking = false
	velocity = Vector2.ZERO
	
	print("Skeleton Tạch!")
	
	GameManager.register_death(str(get_path()))
	#$CollisionShape2D.set_deferred("disabled", true)
	kill_zone_col.set_deferred("disabled", true)
	
	animated_sprite_2d.play("die")
	
	await get_tree().create_timer(0.5).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
	
	spawn_item()

func spawn_item():
	if randf() > drop_chance:
		return
	
	var item_scene = null
	var gacha = randf()
	
	if gacha < 0.6:
		item_scene = health_item_scene
	else:
		item_scene = damage_item_scene
	
	if item_scene:
		var item = item_scene.instantiate()
		item.global_position = global_position
		get_parent().call_deferred("add_child", item)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = true


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_attack_range = false


#func _on_animated_sprite_2d_animation_finished() -> void:
	#if animated_sprite_2d.animation == "Attack":
		#is_attacking = false
		#kill_zone_col.disabled = true
		
		#await get_tree().create_timer(attack_cooldown_time).timeout
		#can_attack = true


func attack():
	if is_dying or is_taking_damage: return
	
	# 1. KHÓA NGAY LẬP TỨC
	is_attacking = true
	can_attack = false # <--- Chặn không cho gọi hàm này lần nữa
	velocity = Vector2.ZERO # Dừng quái lại
	
	# 2. CHƠI ANIMATION
	animated_sprite_2d.play("Attack")
	
	# 3. CHỜ VUNG KIẾM 
	await get_tree().create_timer(0.8).timeout
	
	# Check lại xem trong lúc chờ có bị đánh chết không
	if not is_attacking or is_dying or is_taking_damage:
		kill_zone_col.set_deferred("disabled", true)
		#is_attacking = false
		return

	# 4. BẬT SÁT THƯƠNG
	kill_zone_col.disabled = false 
	
	# 5. GIỮ SÁT THƯƠNG TRONG 0.2 GIÂY
	await get_tree().create_timer(0.2).timeout
	
	# 6. TẮT SÁT THƯƠNG
	kill_zone_col.disabled = true
	
	# 7. CHỜ ANIMATION DIỄN HẾT
	if animated_sprite_2d.animation == "Attack":
		await animated_sprite_2d.animation_finished
	
	# 8. MỞ KHÓA DI CHUYỂN
	is_attacking = false 
	
	# 9. HỒI CHIÊU (Cooldown)
	await get_tree().create_timer(attack_cooldown_time).timeout
	
	# 10. MỞ KHÓA ĐÁNH
	can_attack = true
