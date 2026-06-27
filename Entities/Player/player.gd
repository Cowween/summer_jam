extends CharacterBody2D

class_name Player

@export var SPEED: float = 120.0 # Lower speed usually feels better for snappy RPGs
@export var heat_tick_speed := 5.0
@export var fastest_heat_tick := 0.02
@export var slowest_heat_tick := 2.0
@export var slingshot_cooldown := 0.4
@export var sling_shot_ammo := preload("res://Entities/Weapons/Slingshot/sling_shot_ammo.tscn")
@export var shoot_sound : AudioStream
@export var swing_sound : AudioStream
const CROSSHAIR = preload("uid://dkkwp1mnqfrcc")

@onready var camera := $Camera2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var e: Label = $E

var interacting_area : Interactable = null
var game_data : GameData = GlobalStorage.game_data
var is_input_locked := false
var equipped_item_id := ""
var ambient_temp : float
var current_facing := "down"
var bullet_cd := false
var hammering := false

func _ready() -> void:
	#set_heat_tick(heat_tick_speed)
	camera.position_smoothing_enabled = false
	GameBus.block_player_movement.connect(_on_movement_block)
	GameBus.release_player_movement.connect(_on_movement_release)
	GameBus.temperature_changed.connect(_on_temperature_changed)
	GameBus.weapon_equipped.connect(_on_weapon_equipped)
	GameBus.sledge_hammer_swing.connect(_on_swing)
	
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _physics_process(_delta: float) -> void:
	if hammering:
		return
	# 1. Get input direction (-1, 0, or 1 for both axes)
	var input_direction: Vector2 = Input.get_vector("leftward", "rightward", "forward", "backward")
	
	# 2. Normalize to prevent fast diagonal walking
	input_direction = input_direction.normalized()
	
	# 3. CRITICAL: Set velocity directly with NO interpolation (instant start/stop)
	if input_direction != Vector2.ZERO and not is_input_locked:
		update_facing_direction(input_direction)
		velocity = input_direction * SPEED
		anim_sprite.play("walk_"+current_facing)
	else:
		velocity = Vector2.ZERO # Hard, instant stop
		if equipped_item_id == "pistol":
			anim_sprite.play("gun_"+current_facing)
		elif equipped_item_id == "slingshot":
			anim_sprite.play("sling_"+current_facing)
		else:
			anim_sprite.play("idle_"+current_facing)
	# 4. Move and handle collisions
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interacting_area and not is_input_locked:
		interacting_area.interact()

func _unhandled_input(event: InputEvent) -> void:
	if is_input_locked: 
		return
	
	# If the player left-clicks and has the slingshot equipped...
	if event.is_action_pressed("shoot") and equipped_item_id == "slingshot":
		
		fire_slingshot()
	if event.is_action_pressed("shoot") and equipped_item_id == "pistol":
		
		fire_slingshot()
	
	if event.is_action_pressed("cancel") and equipped_item_id != "":
		GameBus.weapon_equipped.emit(equipped_item_id)


func fire_slingshot() -> void:
	print("here1")
	if not sling_shot_ammo: return
	print("here")
	if bullet_cd: return
	SoundManager.play_sfx(shoot_sound)
	bullet_cd = true
	# 2. Create the projectile
	var ammo: SlingshotAmmo = sling_shot_ammo.instantiate()
	
	# 3. Add it to the active stage (NOT the player, or it will follow the player's movement!)
	get_tree().current_scene.add_child(ammo)
	
	# 4. Position it exactly where the player is currently standing
	ammo.global_position = global_position
	if equipped_item_id == "pistol":
		ammo.is_pistol = true
	
	# 5. Calculate the exact math angle from the player to the mouse cursor
	var mouse_pos = get_global_mouse_position()
	ammo.direction = global_position.direction_to(mouse_pos).normalized()
	await get_tree().create_timer(slingshot_cooldown).timeout
	
	# 4. Unlock the slingshot so they can fire again!
	bullet_cd = false
func slew_to_position(target_pos: Vector2, duration: float = 1.0) -> void:
	# 1. Lock the player's input so they can't walk away during the slew
	is_input_locked = true
	
	# 2. Slam velocity to zero so they don't slide off course
	velocity = Vector2.ZERO 
	
	# 3. Create the Tween (bound to this player node)
	var tween = create_tween()
	
	# 4. Set the transition curve (SINE gives a natural ease-in and ease-out)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 5. Animate the global_position to the target over the specified duration
	tween.tween_property(self, "global_position", target_pos, duration)
	
	# 6. Wait for the animation to completely finish
	await tween.finished
	
	# 7. Give control back to the player!
	is_input_locked = false

func set_heat_tick(time: float) -> void:
	print("Current heat tick: "+str(time))
	$HeatTick.wait_time = time
	$HeatTick.paused = false

func set_camera_ease() -> void:
	camera.position_smoothing_enabled = true
	pass

func die() -> void:
	set_physics_process(false)
	anim_sprite.play("faint")
	await anim_sprite.animation_finished
	return

func update_facing_direction(dir: Vector2) -> void:
	# If the X movement is stronger than the Y movement, face sideways
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			current_facing = "right"
		else:
			current_facing = "left"
	# If the Y movement is stronger, face up or down
	else:
		if dir.y > 0:
			current_facing = "down"
		else:
			current_facing = "up"

func heat_tick_from_temp(temp: float) -> void:
	if temp <= 35.0:
		set_heat_tick(1.0)
	var new_tick := clampf(lerpf(slowest_heat_tick, fastest_heat_tick, temp/100.0),  fastest_heat_tick, slowest_heat_tick)
	set_heat_tick(new_tick)
	
func swing_sledgehammer() -> void:
	if hammering:
		return
	if equipped_item_id != "":
		GameBus.weapon_equipped.emit(equipped_item_id)
	hammering = true
	SoundManager.play_sfx(swing_sound)
	# Optional: Lock input for 0.2 seconds so the player can't spam the hammer
	anim_sprite.play("hammer_"+current_facing)
	if not interacting_area or not interacting_area.is_in_group("sledge"):
		await anim_sprite.animation_finished
		hammering = false
		return
	
	interacting_area.sledge()
	await anim_sprite.animation_finished
	hammering = false
	
	# Optional: Play a heavy "WHOOSH" sound effect here!

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Interactable:
		e.show()
		#print("Entering "+str(area.get_parent()))
		interacting_area = area
		

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is Interactable:
		if area == interacting_area:
			e.hide()
			interacting_area = null


func _on_heat_tick_timeout() -> void:
	if ambient_temp > 35.0:
		game_data.player_core_heat += 1
	else:
		game_data.player_core_heat -= 0.5

func _on_dialogue_started(_resource: DialogueResource) -> void:
	is_input_locked = true
	$HeatTick.paused = true
	
func _on_dialogue_ended(_resource: DialogueResource) -> void:
	is_input_locked = false
	$HeatTick.paused = false
	
func _on_movement_block() -> void:
	is_input_locked = true

func _on_movement_release() -> void:
	is_input_locked = false
	
func _on_temperature_changed(new_temp: float) -> void:
	heat_tick_from_temp(new_temp)
	ambient_temp = new_temp
	
func _on_swing() -> void:
	swing_sledgehammer()


func _on_weapon_equipped(item_id: String) -> void:
	if equipped_item_id != item_id:
		CursorManager.set_aim_mode()
		equipped_item_id = item_id
		game_data.wpn_equipped = true
	else:
		CursorManager.set_default_mode()
		equipped_item_id = ""
		game_data.wpn_equipped = false
