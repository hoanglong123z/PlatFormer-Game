extends Area2D

var speed = 300
var direction = Vector2.RIGHT # Mặc định bắn sang phải
var damage = 1
@onready var kill_zone: Area2D = $KillZone

func _ready():
	kill_zone.monitoring = true
	kill_zone.monitorable = true
	$AnimatedSprite2D.play("fly") 
	
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _process(delta):
	position += direction * speed * delta

	if direction != Vector2.ZERO:
		rotation = direction.angle()
	
	if direction.x < 0:
		$AnimatedSprite2D.flip_v = true 
	else:
		$AnimatedSprite2D.flip_v = false

func _on_kill_zone_body_entered(body: Node2D) -> void:
		if body.is_in_group("Player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
