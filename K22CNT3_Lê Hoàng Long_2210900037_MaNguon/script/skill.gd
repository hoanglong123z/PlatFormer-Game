extends Area2D

@export var speed = 400.0
@export var damage = 2
var direction = Vector2.RIGHT

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionPolygon2D = $CollisionShape2D

func _ready() -> void:
	if direction.x < 0:
		scale.x = -1
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
# Kiểm tra xem vật va chạm có phải là Quái và có hàm nhận damage không
	#if body.has_method("take_damage"):
		#body.take_damage(damage)
		#print("Skill trúng quái: ", body.name)
		#queue_free() # Trúng là nổ (biến mất)
	#elif body is TileMap or body is TileMapLayer: 
		#queue_free()
	# Nếu skill trúng tường/đất (TileMap) thì cũng biến mất
	if body is TileMapLayer or body is TileMap: 
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free() # Skill biến mất
		
	elif area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage) 
		queue_free()
