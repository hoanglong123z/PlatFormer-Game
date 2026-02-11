extends Node

const SAVE_PATH = "user://savegame.save"

var highest_unlocked_level = 1
var golem_defeated = false
# --- DỮ LIỆU GAME ---
var score = 0
var dead_objects = [] # Danh sách ID của Coin/Quái đã chết và ĐÃ ĐƯỢC LƯU
var player_data = {}  # Biến tạm để chứa dữ liệu khi load

@onready var score_label = %ScoreLabel
@onready var pause: Control = %Pause
@onready var pausegame: Button = %Pausegame


var respawn_position = Vector2.ZERO
var start_position = Vector2(-182,151)
signal score_updated

# === HÀM HỖ TRỢ COIN/QUÁI ===
# Kiểm tra xem vật thể này đã "lên bảng đếm số" trong file save chưa
func is_object_dead(node_path: String) -> bool:
	return node_path in dead_objects

# Đăng ký cái chết (Gọi khi ăn coin hoặc giết quái)
func register_death(node_path: String):
	if node_path not in dead_objects:
		dead_objects.append(node_path)

# === HỆ THỐNG SAVE / LOAD ===
func save_game():
	# Lấy Player thực tế đang chơi để lưu vị trí
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print("Không tìm thấy Player để lưu!")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"score": score,
		"scene": get_tree().current_scene.scene_file_path,
		"position": respawn_position,
		"health": player.health,
		"dead_objects": dead_objects,
		"highest_unlocked_level": highest_unlocked_level,
		"golem_defeated": golem_defeated
	}
	file.store_var(data)
	print(">>> GAME SAVED! Vị trí: ", respawn_position)
	print(">>> Đã lưu ", dead_objects.size(), " vật thể đã chết.")
	print(">>> GAME SAVED! Level mở khóa cao nhất: ", highest_unlocked_level)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	
	# [QUAN TRỌNG] Reset RAM và nạp lại từ File
	# Việc này đảm bảo những vật thể "chưa kịp save" sẽ được hồi sinh
	dead_objects = data.get("dead_objects", [])
	score = data.get("score", 0)
	highest_unlocked_level = data.get("highest_unlocked_level", 1)
	golem_defeated = data.get("golem_defeated", false)
	player_data = data # Lưu tạm để Player dùng khi _ready
	
	# Chuyển cảnh
	get_tree().paused = false # Bỏ pause nếu đang pause
	get_tree().change_scene_to_file(data["scene"])
	print(">>> LOAD GAME! Level mở khóa: ", highest_unlocked_level)

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	# Reset dữ liệu RAM
	score = 0
	dead_objects = []
	player_data = {}
	respawn_position = start_position

func _ready() -> void:
	pass
func add_point():
	score += 1
	if score_label:
		score_label.text = str(score)
	score_updated.emit()

func unlock_level(level_index):
	if level_index > highest_unlocked_level:
		highest_unlocked_level = level_index
		print("Chúc mừng! Đã mở khoá level ", level_index)
		save_game()

func _on_pausegame_pressed() -> void:
	if get_tree().paused:
		pause.resume()
		pausegame.visible = true
	else:
		pause.pause()
		pausegame.visible = false

func reset_game_data():
	print("--- ĐANG RESET DỮ LIỆU ---")
	score = 0 
	dead_objects = []
	respawn_position = start_position
	CheckPoint.last_position = null
	golem_defeated = false

func reset_checkpoint():
	respawn_position = Vector2.ZERO

func has_loaded_data() -> bool: return not player_data.is_empty()
func get_loaded_position() -> Vector2: return player_data["position"]
func get_loaded_health() -> int: return player_data["health"]
func clear_loaded_data(): player_data = {}
