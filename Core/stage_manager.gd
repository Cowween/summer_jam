extends Node
class_name StageManager

@export_enum("following", "stand_still", "distracted") var initial_friend_state : String
@export_file("*.tscn") var starting_scene : String
@export var spawn_list : Array[Node2D]
@export var ui : CanvasLayer
@export var base_temp := 45.0
@export var is_room := false
@export var stage_id := 0


@onready var player := %Player
@onready var friend := %Friend
@onready var inventory := $InventoryInterface
@onready var tilemap := $TileMapLayer

var game_data : GameData = GlobalStorage.game_data

var current_temp : float :
	set(value):
		current_temp = value
		GameBus.temperature_changed.emit(value)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	configure_camera_limits()
	handle_spawn()
	GameBus.player_heat_changed.connect(_player_heat_changed)
	GameBus.refresh_temp.connect(_on_temp_refresh)
	current_temp = base_temp
	game_data.player_core_heat = game_data.player_core_heat
	if game_data.is_inventory_open:
		inventory.show_inventory()
	else:
		inventory.hide_inventory()
	match initial_friend_state:
		
		"following":
			friend.current_state = friend.State.FOLLOWING
		"stand_still":
			friend.current_state = friend.State.STAND_STILL
		"distracted":
			friend.current_state = friend.State.DISTRACTED

func handle_spawn() -> void:
	var spawn_node := spawn_list[game_data.next_spawn]
	var spawn := spawn_node.get_node("Spawn")
	var friend_spawn := spawn_node.get_node("FriendSpawn")
	player.global_position = spawn.global_position
	friend.global_position = friend_spawn.global_position
	await get_tree().process_frame
	player.set_camera_ease()
	
func configure_camera_limits() -> void:

	
	# 1. Grab the camera component sitting inside your player scene
	var camera: Camera2D = player.camera
	
	# 2. Get the rectangle of used tiles in tile coordinates (e.g., 0 to 100 tiles)
	var map_rect: Rect2i = tilemap.get_used_rect()
	
	# 3. Get the size of an individual tile in pixels (e.g., 16 or 32)
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	
	# 4. Multiply tile coordinates by pixel sizes to get true pixel boundaries
	camera.limit_left = map_rect.position.x * tile_size.x
	camera.limit_right = map_rect.end.x * tile_size.x
	camera.limit_top = map_rect.position.y * tile_size.y
	camera.limit_bottom = map_rect.end.y * tile_size.y

func refresh_temp() -> void:
	current_temp = base_temp - game_data.permanent_temp_dec - game_data.stage_temp_dec[stage_id]

func _new_loop() -> void:
	game_data.is_reset = true
	game_data.next_spawn = 0
	get_tree().change_scene_to_file(starting_scene)

func _player_heat_changed(new_heat: float) -> void:
	if new_heat >= 100.0:
		_new_loop()
		
func _on_temp_refresh() -> void:
	refresh_temp()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
