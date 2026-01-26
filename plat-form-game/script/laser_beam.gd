extends Area2D

var speed = 600 
var direction = Vector2.RIGHT
var damage = 1
@onready var kill_zone: Area2D = $KillZone

func _ready():
	kill_zone.monitoring = false
	kill_zone.monitorable = false
	$AnimatedSprite2D.play("charge")
	
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.play("fire")
	kill_zone.monitoring = true
	kill_zone.monitorable = true
	# Tự huỷ
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
