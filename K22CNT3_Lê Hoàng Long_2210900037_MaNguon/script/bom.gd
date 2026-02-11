extends Area2D

var speed = 300
var direction = Vector2.ZERO
var damage = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play("Explosion")
	
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	elif body is TileMapLayer or body.name == "LevelMap":
		queue_free()
