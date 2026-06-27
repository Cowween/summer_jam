extends Node
class_name StageManager

@export_enum("following", "stand_still", "distracted") var initial_friend_state : String
@export_file("*.tscn") var starting_scene : String
@export var stage_script : DialogueResource
@export var spawn_list : Array[Node2D]
@export var ui : CanvasLayer
@export var base_temp := 45.0
@export var is_room := false
@export var stage_id := 0
@export var background_sprite : CanvasItem
@export var background_music : AudioStream

@onready var player : Player = %Player
@onready var friend : Friend = %Friend
@onready var inventory := $InventoryInterface
@onready var tilemap := $FloorLayer
@onready var fade_out: ColorRect = $EffectsLayer/FadeOut

var game_data : GameData = GlobalStorage.game_data
var is_dying := false

var current_temp : float :
	set(value):
		current_temp = value
		GameBus.temperature_changed.emit(value)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	CursorManager.set_default_mode()
	SoundManager.play_bg(background_music)
	if not background_sprite:
		configure_camera_limits()
	else:
		lock_camera_to_background()
	handle_spawn()
	GameBus.player_heat_changed.connect(_player_heat_changed)
	GameBus.refresh_temp.connect(_on_temp_refresh)
	GameBus.anomaly_solved.connect(_on_anomaly_solved)
	game_data.wpn_equipped = false
	refresh_temp()
	current_temp = current_temp
	game_data.last_stage = game_data.current_stage
	game_data.current_stage = stage_id
	game_data.player_core_heat = game_data.player_core_heat
	if game_data.is_inventory_open:
		inventory.show_inventory()
	else:
		inventory.hide_inventory()
	if not game_data.is_friend_following:
		friend.global_position = $FriendInitialSpawn.global_position
		set_friend_state("stand_still")
	else:
		set_friend_state("following")

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
func lock_camera_to_background() -> void:

	if not background_sprite:
		push_error("Missing background sprite, texture, or camera!")
		return
	var camera = player.camera
	# 1. Get the base pixel size of the image
	var tex_size = background_sprite.texture.get_size()
	
	# 2. Multiply by scale (just in case you made the background bigger in the editor)
	var bg_scale = background_sprite.global_scale
	var actual_width = tex_size.x * bg_scale.x
	var actual_height = tex_size.y * bg_scale.y
	
	# 3. Calculate the boundaries based on the sprite's origin point
	var left_limit: float
	var top_limit: float
	
	# Godot sprites are centered by default. We have to account for that!
	if background_sprite.centered:
		left_limit = background_sprite.global_position.x - (actual_width / 2.0)
		top_limit = background_sprite.global_position.y - (actual_height / 2.0)
	else:
		left_limit = background_sprite.global_position.x
		top_limit = background_sprite.global_position.y
		
	var right_limit = left_limit + actual_width
	var bottom_limit = top_limit + actual_height

	# 4. Inject these boundaries directly into the camera
	camera.limit_left = int(left_limit)
	camera.limit_top = int(top_limit)
	camera.limit_right = int(right_limit)
	camera.limit_bottom = int(bottom_limit)

func refresh_temp() -> void:
	current_temp = base_temp - game_data.permanent_temp_dec - game_data.stage_temp_dec[stage_id]

func set_friend_state(state: String) -> void:
	match state:
		
		"following":
			friend.set_state(Friend.State.FOLLOWING)
		"stand_still":
			friend.set_state(Friend.State.STAND_STILL)
		"distracted":
			friend.current_state = friend.State.DISTRACTED

func _new_loop() -> void:
	is_dying = true
	GameBus.block_player_movement.emit()
	player.die()
	var tween := create_tween()
	tween.tween_property(fade_out, "color:a", 1.0 ,3.5)
	await tween.finished
	game_data.loop()
	get_tree().change_scene_to_file(starting_scene)

func _player_heat_changed(new_heat: float) -> void:
	if is_dying:
		return
	if new_heat >= 100.0 and not game_data.god_mode:
		_new_loop()
		
func _on_temp_refresh() -> void:
	refresh_temp()
	
func _on_anomaly_solved() -> void:
	for a in $Anomalies.get_children():
		if not game_data.solved_anomalies.has(a.anomaly_id):
			return
			
