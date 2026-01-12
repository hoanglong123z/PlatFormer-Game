extends Node2D

const  SPEED = 60
var direction = 1

var health = 2
var is_dying = false

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dying:
		return
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

func take_damage(amount):
	if is_dying:
		return
	health -= amount
	print("Quái bị chém! Máu còn: ", health)
	
	var tween = create_tween()
	animated_sprite.modulate = Color(10,0,0)
	tween.tween_property(animated_sprite,"modulate",Color(1,1,1), 0.2)
	
	if health <= 0:
		die()
func die():
	is_dying = true
	print("Tạch!")
	
	if has_node("KillZone"):
		$KillZone.queue_free()
	animated_sprite.play("die")
	await get_tree().create_timer(0.5).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
