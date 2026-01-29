extends CanvasLayer

@onready var portrait: TextureRect = $Panel/Portrait
@onready var content: RichTextLabel = $Panel/Content
@onready var panel: Panel = $Panel

var current_tween: Tween

func _ready() -> void:
	panel.hide()


func start_dialogue(text_content: String, face_image: Texture2D):
	panel.show()
	#get_tree().paused = true
	
	portrait.texture = face_image
	content.text = text_content
	content.visible_ratio = 0.0
	
	if current_tween: current_tween.kill() 
	current_tween = create_tween()
	current_tween.tween_property(content, "visible_ratio", 1.0, 2.0)

func _input(event):
	if event.is_action_pressed("interact") and panel.visible:
		if content.visible_ratio < 1.0:
			content.visible_ratio = 1.0
			if current_tween: current_tween.kill()
		else:
			close_dialogue()

func close_dialogue():
	panel.hide()
	#get_tree().paused = false
	queue_free()
