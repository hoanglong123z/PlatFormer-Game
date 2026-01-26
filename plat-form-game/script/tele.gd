extends Area2D

@export var require_golem_dead = false
@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	# Ẩn label ngay khi game bắt đầu
	if label:
		label.modulate.a = 0
		label.hide()
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if require_golem_dead == true and GameManager.golem_defeated == false:
			print("Cửa khoá! Phải tiêu diệt Golem nhé")
			if label:
				label.show()
				var tween = create_tween()
				tween.tween_property(label, "modulate:a", 1.0, 0.5)
				tween.tween_interval(1.0)
				tween.tween_property(label, "modulate:a", 0.0, 0.5)
				tween.tween_callback(label.hide)
			return
		if $Point:
			body.set_position($Point.global_position)
			print("Dịch chuyển thành công")
