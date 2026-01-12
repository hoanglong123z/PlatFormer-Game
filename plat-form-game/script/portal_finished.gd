extends Node2D

@onready var label: Label = $CanvasLayer/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if label:
		label.modulate.a = 0
		label.hide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Đã Chạm Cổng! Victory")
		
		if label:
			label.show()
			var tween = create_tween()
			tween.tween_property(label, "modulate:a", 1.0, 1.5)
		
		
		await get_tree().create_timer(2.5).timeout
		
		get_tree().change_scene_to_file("res://Scenes/levelmap.tscn")
