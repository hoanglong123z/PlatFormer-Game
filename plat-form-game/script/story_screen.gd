extends Control

@onready var label: Label = $Label
var content = ""

func _ready() -> void:
	if label:
		label.text = content
		
		label.visible_ratio = 0.0
		
		var tween = create_tween()
		
		tween.tween_property(label, "visible_ratio", 1.0, 3.0)
		
	get_tree().paused = true

func  _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			if label and label.visible_ratio < 1.0:
				label.visible_ratio = 1.0
			else:
				close_story()

func close_story():
	get_tree().paused = false
	if get_parent() is CanvasLayer:
		get_parent().queue_free()
	else:
		queue_free()
