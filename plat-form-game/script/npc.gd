extends CharacterBody2D

@export var required_coins = 100
@export var is_gatekeeper: bool = false
@export_multiline var mockery_text: String
@export_multiline var success_text: String = ""
@export_multiline var dialogue_text: String = ""
@export var face_texture: Texture2D 
@export var dialogue_scene: PackedScene
@onready var label: Label = $Label
@onready var area_2d: Area2D = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_in_range = false
var is_chatting = false
var current_player_ref = null

func _ready() -> void:
	label.hide()
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)

func _process(delta: float) -> void:
	if is_in_range and Input.is_action_just_pressed("interact") and not is_chatting:
		face_player()
		open_dialogue()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_in_range = true
		current_player_ref = body
		label.show()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_in_range = false
		current_player_ref = body
		label.hide()

func open_dialogue():
	if dialogue_scene:
		is_chatting = true
		var final_text = dialogue_text
		if is_gatekeeper:
			if GameManager.score >= required_coins:
				final_text = success_text
			else:
				pass
		
		var box = dialogue_scene.instantiate()
		get_tree().root.add_child(box)
		
		box.call_deferred("start_dialogue", final_text, face_texture)
		
		box.tree_exited.connect(_on_dialogue_closed)

func _on_dialogue_closed():
	await get_tree().create_timer(0.2).timeout

	is_chatting = false

func face_player():
	if current_player_ref == null:
		return
	var direction = current_player_ref.global_position.x - global_position.x
	
	if direction < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.position.x = -5
	else:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.position.x = 7
