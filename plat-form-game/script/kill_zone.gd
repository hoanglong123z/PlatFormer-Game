extends Area2D

@onready var timer = $Timer
@onready var died_sfx: AudioStreamPlayer2D = $DiedSFX
@onready var die: Label = $CanvasLayer/die
@onready var gameover: Label = $CanvasLayer/gameover


func _ready() -> void:
	if die:
		die.modulate.a = 0
		die.hide()
	if gameover:
		gameover.modulate.a = 0
		gameover.hide()
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.is_dying == true:
			return
		var bi_danh_trung = false
		if body.has_method("take_damage"):
			bi_danh_trung = body.take_damage()
		if not bi_danh_trung:
			return
		body.is_dying = true
		if body.has_method("take_damage"):
			body.take_damage()
			died_sfx.play()
		if body.health <= 0:
			print("Game Over")
			died_sfx.play()
			Engine.time_scale = 0.5
			body.set_physics_process(false)
		#body.get_node("CollisionShape2D").queue_free()
		if body.health >= 1:
			die.show()
			var tween = create_tween()
			tween.tween_property(die, "modulate:a", 1.0, 0.5)
			tween.tween_interval(0.5)
			tween.tween_property(die,"modulate:a", 0.0, 0.5)
			tween.tween_callback(die.hide)
			body.set_physics_process(false)
		elif body.health <= 0:
			gameover.show()
			var tween = create_tween()
			tween.tween_property(gameover, "modulate:a", 1.0, 0.5)
			tween.tween_interval(0.5)
			tween.tween_property(gameover,"modulate:a", 0.0, 0.5)
			tween.tween_callback(gameover.hide)
			timer.start(0.9)
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	#get_tree().reload_current_scene()
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_dying = false
		if player.health <= 0:
			GameManager.reset_game_data()
			get_tree().reload_current_scene()
		else:
			player.global_position = GameManager.respawn_position
			
			player.velocity = Vector2.ZERO
			
			player.set_physics_process(true)
			
