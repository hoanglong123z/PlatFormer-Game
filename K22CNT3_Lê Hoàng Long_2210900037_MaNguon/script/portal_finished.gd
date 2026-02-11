extends Node2D

@onready var label: Label = $CanvasLayer/Label
@onready var label_2: Label = $CanvasLayer/Label2

@export var required_score = 100 
@export var level_to_unlock = 2  
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if label:
		label.modulate.a = 0
		label.hide()
	if label_2:
		label_2.modulate.a = 0
		label_2.hide()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Đã Chạm Cổng! Kiểm tra điều kiện...")
		
		if GameManager.score >= required_score:
			print("ĐỦ ĐIỀU KIỆN! (Vàng: ", GameManager.score, "/", required_score, ")")
			
			GameManager.unlock_level(level_to_unlock)
			
			if label:
				label.show()
				var tween = create_tween()
				tween.tween_property(label, "modulate:a", 1.0, 1.5)
				#tween.tween_interval(1.0)
				#tween.tween_property(label, "modulate:a", 0.0, 0.5)
				#tween.tween_callback(label.hide)
			await get_tree().create_timer(2.5).timeout
			get_tree().change_scene_to_file("res://Scenes/levelmap.tscn")
		else:
			print("CHƯA ĐỦ VÀNG! (Có: ", GameManager.score, " - Cần: ", required_score, ")")
			if label_2:
				label_2.text = "Cần " + str(required_score) + " Coins!"
				label_2.modulate.a = 0 
				label_2.show()
				var tween = create_tween()
				tween.tween_property(label_2, "modulate:a", 1.0, 0.5)
				tween.tween_interval(1.0)
				tween.tween_property(label_2, "modulate:a", 0.0, 0.5)
				tween.tween_callback(label_2.hide)
