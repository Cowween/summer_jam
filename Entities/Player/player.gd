extends CharacterBody2D

class_name Player

@export var SPEED: float = 120.0 # Lower speed usually feels better for snappy RPGs
@export var heat_tick_speed := 5.0
@export var fastest_heat_tick := 0.02
@export var slowest_heat_tick := 2.0
@export var sling_shot_ammo := preload("res://Entities/Weapons/Slingshot/sling_shot_ammo.tscn")

@onready var camera := $Camera2D

var interacting_area : Interactable = null
var game_data : GameData = GlobalStorage.game_data
var is_input_locked := false
var equipped_item_id := ""
var ambient_temp : float


func _ready() -> void:
	#set_heat_tick(heat_tick_speed)
	camera.position_smoothing_enabled = false
	GameBus.block_player_movement.connect(_on_movement_block)
	GameBus.release_player_movement.connect(_on_movement_release)
	GameBus.temperature_changed.connect(_on_temperature_changed)
	GameBus.weapon_equipped.connect(_on_weapon_equipped)
	
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _physics_process(_delta: float) -> void:
	# 1. Get input direction (-1, 0, or 1 for both axes)
	var input_direction: Vector2 = Input.get_vector("leftward", "rightward", "forward", "backward")
	
	# 2. Normalize to prevent fast diagonal walking
	input_direction = input_direction.normalized()

	# 3. CRITICAL: Set velocity directly with NO interpolation (instant start/stop)
	if input_direction != Vector2.ZERO and not is_input_locked:
		velocity = input_direction * SPEED
	else:
		velocity = Vector2.ZERO # Hard, instant stop

	# 4. Move and handle collisions
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interacting_area and not is_input_locked:
		interacting_area.interact()

func _unhandled_input(event: InputEvent) -> void:
	if is_input_locked: return
	
	# If the player left-clicks and has the slingshot equipped...
	if event.is_action_pressed("shoot") and equipped_item_id == "slingshot":
		fire_slingshot()
	
	if event.is_action_pressed("cancel") and equipped_item_id != "":
		equipped_item_id = ""

func fire_slingshot() -> void:
	if not sling_shot_ammo: return
	
	# 2. Create the projectile
	var ammo: SlingshotAmmo = sling_shot_ammo.instantiate()
	
	# 3. Add it to the active stage (NOT the player, or it will follow the player's movement!)
	get_tree().current_scene.add_child(ammo)
	
	# 4. Position it exactly where the player is currently standing
	ammo.global_position = global_position
	
	# 5. Calculate the exact math angle from the player to the mouse cursor
	var mouse_pos = get_global_mouse_position()
	ammo.direction = global_position.direction_to(mouse_pos).normalized()

func set_heat_tick(time: float) -> void:
	print("Current heat tick: "+str(time))
	$HeatTick.wait_time = time
	$HeatTick.paused = false

func set_camera_ease() -> void:
	camera.position_smoothing_enabled = true
	pass

func heat_tick_from_temp(temp: float) -> void:
	if temp <= 35.0:
		set_heat_tick(1.0)
	var new_tick := lerpf(slowest_heat_tick, fastest_heat_tick, temp/100.0)
	set_heat_tick(new_tick)

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Interactable:
		interacting_area = area
		

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is Interactable:
		interacting_area = null


func _on_heat_tick_timeout() -> void:
	if ambient_temp > 35.0:
		game_data.player_core_heat += 1
	else:
		game_data.player_core_heat -= 0.5

func _on_dialogue_started(_resource: DialogueResource) -> void:
	is_input_locked = true
	
func _on_dialogue_ended(_resource: DialogueResource) -> void:
	is_input_locked = false
	
func _on_movement_block() -> void:
	is_input_locked = true

func _on_movement_release() -> void:
	is_input_locked = false
	
func _on_temperature_changed(new_temp: float) -> void:
	heat_tick_from_temp(new_temp)
	ambient_temp = new_temp
	
func _on_weapon_equipped(item_id: String) -> void:
	if equipped_item_id == "":
		equipped_item_id = item_id
	else:
		equipped_item_id = ""
