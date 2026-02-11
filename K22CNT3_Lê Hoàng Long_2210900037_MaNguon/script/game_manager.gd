extends Node

const SAVE_PATH = "user://savegame.save"

var highest_unlocked_level = 1
var golem_defeated = false

# --- DỮ LIỆU GAME ---
var score = 0
var dead_objects = [] # Danh sách ID đã chết
var player_data = {}  # Biến tạm load game

# Biến lưu tọa độ hồi sinh (Checkpoint)
var respawn_position = Vector2.ZERO 
var start_position = Vector2.ZERO
# UI References (Lưu ý: Nếu GameManager là Autoload, đảm bảo các node này có trong scene Autoload hoặc xử lý cẩn thận)
@onready var score_label = %ScoreLabel
@onready var pause: Control = %Pause
@onready var pausegame: Button = %Pausegame

signal score_updated

# === 1. HÀM QUAN TRỌNG NHẤT: RESET GAME ===
# Gọi hàm này khi bấm "New Game" hoặc "Vào Màn 1" từ Menu
func reset_game_state():
	print(">>> ĐANG RESET GAME STATE...")
	score = 0 
	dead_objects = [] 
	player_data = {}
	
	# QUAN TRỌNG: Đưa về 0 để Player tự tìm StartPoint ở màn mới
	respawn_position = Vector2.ZERO 
	
	# Reset trạng thái các biến khác nếu cần (ví dụ giữ nguyên level đã mở khóa)
	# golem_defeated = false 

# === 2. HỆ THỐNG COIN/QUÁI ===
func is_object_dead(node_path: String) -> bool:
	return node_path in dead_objects

func register_death(node_path: String):
	if node_path not in dead_objects:
		dead_objects.append(node_path)

# === 3. HỆ THỐNG SAVE / LOAD ===
func save_game():
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print("Không tìm thấy Player để lưu!")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"score": score,
		"scene": get_tree().current_scene.scene_file_path,
		"position": respawn_position, # Lưu vị trí checkpoint hiện tại
		"health": player.health,
		"dead_objects": dead_objects,
		"highest_unlocked_level": highest_unlocked_level,
		"golem_defeated": golem_defeated
	}
	file.store_var(data)
	print(">>> GAME SAVED! Checkpoint: ", respawn_position)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("Không tìm thấy file save!")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	
	# Nạp dữ liệu vào RAM
	dead_objects = data.get("dead_objects", [])
	score = data.get("score", 0)
	highest_unlocked_level = data.get("highest_unlocked_level", 1)
	golem_defeated = data.get("golem_defeated", false)
	
	# Lưu tạm dữ liệu Player để script Player tự lấy khi _ready
	player_data = data 
	
	# Chuyển cảnh
	get_tree().paused = false 
	if data.has("scene"):
		get_tree().change_scene_to_file(data["scene"])
		print(">>> LOAD GAME THÀNH CÔNG!")
	else:
		print("File save bị lỗi: Không có thông tin Scene")

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	reset_game_state() # Xóa luôn dữ liệu trong RAM

# === 4. CÁC HÀM HỖ TRỢ KHÁC ===
func add_point():
	score += 1
	if score_label:
		score_label.text = str(score)
	score_updated.emit()

func unlock_level(level_index):
	if level_index > highest_unlocked_level:
		highest_unlocked_level = level_index
		print("Chúc mừng! Đã mở khoá level ", level_index)
		save_game() # Lưu game ngay khi mở khóa màn mới

# Xử lý nút Pause (Chỉnh lại logic chuẩn Godot)
func _on_pausegame_pressed() -> void:
	var is_paused = get_tree().paused
	get_tree().paused = not is_paused # Đảo ngược trạng thái
	
	if pause:
		pause.visible = not is_paused # Nếu đang pause thì hiện menu
	if pausegame:
		pausegame.visible = is_paused # Nếu đang pause thì ẩn nút pause

# Các hàm Getter/Setter cho Player dùng
func has_loaded_data() -> bool: 
	return not player_data.is_empty()

func get_loaded_position() -> Vector2: 
	if player_data.has("position"):
		return player_data["position"]
	return Vector2.ZERO

func get_loaded_health() -> int: 
	if player_data.has("health"):
		return player_data["health"]
	return 3

func clear_loaded_data(): 
	player_data = {}
