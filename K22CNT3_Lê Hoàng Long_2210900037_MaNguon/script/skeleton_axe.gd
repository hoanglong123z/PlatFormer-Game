extends CharacterBody2D


@export var axe_scene: PackedScene
@export var throw_speed = 400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

var player = null
var can_attack = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	velocity.x = 0
	move_and_slide()
	
	if player != null:
		face_player()
		
		if can_attack:
			throw_weapon()
	else:
		sprite.play("idle")

func face_player():
	if player.global_position.x < global_position.x:
		sprite.flip_h = true
		spawn_point.position.x = -abs(spawn_point.position.x)
	else:
		sprite.flip_h = false
		spawn_point.position.x = abs(spawn_point.position.x)

func throw_weapon():
	can_attack = false
	sprite.play("attack")
	
	await get_tree().create_timer(0.3).timeout
	
	if axe_scene:
		var axe = axe_scene.instantiate()
		axe.global_position = spawn_point.global_position
		
		if player:
			var dir = (player.global_position - spawn_point.global_position).normalized()
			axe.direction = dir
			axe.speed = throw_speed
		get_parent().add_child(axe)
	
	attack_timer.start()
	await attack_timer.timeout
	can_attack = true

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
