extends CharacterBody2D

var speed = 60
var player = null 
var is_attacking = false 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var kill_zone_col: CollisionShape2D = $KillZone/CollisionShape2D

func _ready() -> void:
	kill_zone_col.disabled = true
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	
	if player:
		var direction = 0
		if player.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
		
		velocity.x = direction * speed
		
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true
		
		if direction > 0:
			animated_sprite_2d.position.x = 4
		else:
			animated_sprite_2d.position.x = -6
			
		animated_sprite_2d.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite_2d.play("idle")
		
	move_and_slide()
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking:
		attack()


func _on_attack_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "Attack":
			is_attacking = false
			kill_zone_col.disabled = true

func attack():
	is_attacking = true
	animated_sprite_2d.play("Attack")
	
	await get_tree().create_timer(0.2).timeout
	
	kill_zone_col.disabled = false
	await get_tree().create_timer(0.3).timeout
	kill_zone_col.disabled = true
