extends Area2D

const  SPEED = 60
var direction = 1

var health = 2
var is_dying = false
var is_taking_damage = false

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var ground_right: RayCast2D = $GroundRight
@onready var ground_left: RayCast2D = $GroundLeft

@export_category("Drop Items")
@export var health_item_scene: PackedScene
@export var damage_item_scene: PackedScene
@export var drop_chance = 0.5

func _ready() -> void:
	var my_id = str(get_path())
	if GameManager.is_object_dead(my_id):
		queue_free()
		return
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)
	
	animated_sprite.play("default")
func _process(delta: float) -> void:
	if is_dying or is_taking_damage:
		return
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta
	if direction > 0:
		animated_sprite.flip_h = false 
	else:
		animated_sprite.flip_h = true


func take_damage(amount, source_pos = Vector2.ZERO):
	if is_dying:
		return
	health -= amount
	print("Quái bị chém! Máu còn: ", health)
	
	if health > 0:
		is_taking_damage = true
		animated_sprite.play("hurt")

		var knockback_tween = create_tween()
		var push_dir = -direction 
		if source_pos != Vector2.ZERO:
			push_dir = sign(global_position.x - source_pos.x)
			if push_dir == 0: push_dir = 1
			if push_dir > 0:
				animated_sprite.flip_h = false 
				#direction = -1
			else:
				animated_sprite.flip_h = true
				#direction = 1
		ray_cast_right.force_raycast_update()
		ray_cast_left.force_raycast_update()
		ground_right.force_raycast_update()
		ground_left.force_raycast_update()
		
		var is_safe = true
		if push_dir > 0:
			if ray_cast_right.is_colliding() or not ground_right.is_colliding():
				is_safe = false
		elif push_dir < 0:
			if ray_cast_left.is_colliding() or not ground_left.is_colliding():
				is_safe = false
		if is_safe:
			var target_pos = position.x + (push_dir * 15)
			knockback_tween.tween_property(self, "position:x", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			print("Kẹt Tường/Vực -> không đẩy lùi!")
			knockback_tween.tween_interval(0.2)
		knockback_tween.tween_callback(func(): is_taking_damage = false)
	else:
		die()

func die():
	is_dying = true
	is_taking_damage = true
	print("Tạch!")
	GameManager.register_death(str(get_path()))
	if has_node("KillZone/CollisionShape2D"):
		$KillZone/CollisionShape2D.set_deferred("disabled", true)
	elif has_node("KillZone"):
		$KillZone.queue_free()
	
	animated_sprite.play("die")
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

func _on_animation_finished():
	if animated_sprite.animation == "hurt":
		is_taking_damage = false
		animated_sprite.play("default")
