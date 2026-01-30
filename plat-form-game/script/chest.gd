extends StaticBody2D

@export var coin_scene: PackedScene
@export var coin_amount = 5

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var interaction_area: Area2D = $InteractionArea
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var player_in_range = false
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("idle")
	label.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and not is_open:
		if Input.is_action_just_pressed("interact"):
			open_chest()

func open_chest():
	is_open = true
	label.hide()
	
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play("open")
	spawn_coins()

func spawn_coins():
	if coin_scene == null: 
		return
	
	for i in range(coin_amount):
		var coin = coin_scene.instantiate()
		get_parent().call_deferred("add_child", coin)
		
		coin.global_position = spawn_point.global_position
		
		var target_pos = coin.global_position
		target_pos.x += randf_range(-60, 60)
		target_pos.y += randf_range(-15, 0)
		
		var jump_height = randf_range(-80, -120)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(coin, "global_position:x", target_pos.x, 0.5)
		
		var jump_tween = create_tween()
		jump_tween.tween_property(coin, "global_position:y", spawn_point.global_position.y + jump_height, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		jump_tween.tween_property(coin, "global_position:y", target_pos.y, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		
		await get_tree().create_timer(0.1).timeout

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		if not is_open:
			label.show()


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		label.hide()
