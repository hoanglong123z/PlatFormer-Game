extends Area2D

@export var story_scene: PackedScene

@export_multiline var story_text: String = ""
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		print("Đã nhặt bí kíp!")
		
		if story_scene:
			var canvas_layer = CanvasLayer.new()
			canvas_layer.layer = 100
			
			var cutscene = story_scene.instantiate()
			cutscene.content = story_text
			
			canvas_layer.add_child(cutscene)
			
			get_tree().root.add_child(canvas_layer)

		else:
			print("Lỗi!")
		
		queue_free()
