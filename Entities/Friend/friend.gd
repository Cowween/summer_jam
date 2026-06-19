extends CharacterBody2D

class_name Friend

enum State { FOLLOWING, STAND_STILL, DISTRACTED }

@export var SPEED: float = 110.0 # Slightly slower or faster than player
@export var STOPPING_DISTANCE: float = 40.0 # Distance to stop behind player
@export var target_node: Node2D = null
@export var puzzle1 : ThoughtPuzzleResource
@export var puzzle2 : ThoughtPuzzleResource
@export var puzzle3 : ThoughtPuzzleResource
@export var friend_script : DialogueResource
@export var gun := preload("res://Entities/Weapons/Pistol/pistol.tres")
@export var thought_interface : ThoughtPuzzle
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var glitch: ColorRect = $Glitch
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

const DSGN_ERIE_EERIE_02_IN_MOTION_AUDIO_SINISTER_TEXTURES_VOLUME_2 = preload("uid://bvowlyd1xevty")

var current_state: State = State.FOLLOWING
var game_data : GameData = GlobalStorage.game_data
var distracted_position: Vector2 = Vector2.ZERO
var mouse_in := false
var sus : Array[String]
var current_facing: String = "down"
var p_toggle := false

signal arrived

func _ready() -> void:
	
	# Listen to the global signal bus for when anomalies change their behavior
	GameBus.anomaly_pondered.connect(_on_anomaly_solved)
	GameBus.friend_sus.connect(_on_friend_sus)
	sus = [puzzle1.anomaly_id, puzzle2.anomaly_id, puzzle3.anomaly_id]
	if game_data.suspect_friend:
		glitch.show()
	else:
		glitch.hide()
	if game_data.friend_revealed:
		anim_sprite = $EvilSprite
		anim_sprite.show()
		$AnimatedSprite2D.hide()

func _physics_process(_delta: float) -> void:
	match current_state:
		State.FOLLOWING:
			handle_following_logic()
		State.STAND_STILL:
			game_data.is_friend_following = false
			velocity = Vector2.ZERO # Do absolutely nothing
		State.DISTRACTED:
			handle_distracted_logic()
	update_animations()
	move_and_slide()
func update_animations() -> void:
	# If the friend is moving fast enough, play the walk animation
	if velocity.length() > 5.0: # 5.0 is a tiny deadzone so they don't jitter
		update_facing_direction(velocity.normalized())
		anim_sprite.play("walk_" + current_facing)
	else:
		anim_sprite.play("idle_" + current_facing)

func update_facing_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			current_facing = "right"
		else:
			current_facing = "left"
	else:
		if dir.y > 0:
			current_facing = "down"
		else:
			current_facing = "up"
func handle_following_logic() -> void:
	if not target_node: return
	game_data.is_friend_following = true
	var distance_to_player = global_position.distance_to(target_node.global_position)

	# Only walk if the player is further away than the stopping comfort zone
	if distance_to_player > STOPPING_DISTANCE:
		nav_agent.target_position = target_node.global_position
		var next_path_pos = nav_agent.get_next_path_position()
		
		# Snappy, instant movement direction calculation
		var direction = global_position.direction_to(next_path_pos).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p_toggle"):
		p_toggle = true
		if not game_data.wpn_equipped and mouse_in and game_data.suspect_friend:
			CursorManager.set_ponder_mode()
	if event.is_action_released("p_toggle"):
		p_toggle = false
		if not game_data.wpn_equipped and game_data.suspect_friend:
			CursorManager.set_default_mode()
	if event.is_action_pressed("ponder") and mouse_in and not game_data.friend_revealed and game_data.suspect_friend:
		ponder_friend()

func handle_distracted_logic() -> void:
	game_data.is_friend_following = false
	var distance_to_distraction = global_position.distance_to(distracted_position)
	
	# Walk toward the distracted target position (like the broken AC)
	if distance_to_distraction > 10.0:
		nav_agent.target_position = distracted_position
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO # Arrived at distraction
		arrived.emit()

# Public functions you can trigger via zone triggers or interactions
func set_state(new_state: State) -> void:
	current_state = new_state
	if new_state == State.FOLLOWING and game_data.friend_revealed:
		timer.start(randf_range(1, 120))
	else:
		timer.stop()

func distract_to(global_pos: Vector2) -> void:
	distracted_position = global_pos
	set_state(State.DISTRACTED)

func ponder_friend() -> void:
	match game_data.suspicion_state:
		0:
			thought_interface.open_puzzle(puzzle1)
		1:
			thought_interface.open_puzzle(puzzle2)
		2:
			thought_interface.open_puzzle(puzzle3)


func _on_anomaly_solved(id: String, solved: String) -> void:
	if not id in sus:
		return
	if solved == "correct":
		game_data.suspicion_state += 1
	if game_data.suspicion_state == 3:
		game_data.friend_revealed = true
		game_data.suspect_friend = false
		game_data.remove_item_by_id("slingshot")
		game_data.add_item(gun)
		anim_sprite = $EvilSprite
		anim_sprite.show()
		$AnimatedSprite2D.hide()
		glitch.hide()
		add_to_group("shootable")


func _on_friend_sus() -> void:
	glitch.show()
	game_data.suspect_friend = true
	
	
func take_bullet_damage(is_pistol: bool) -> void:
	GameBus.killed.emit()
	game_data.friend_killed = true
	remove_from_group("shootable")
	SoundManager.play_bg(DSGN_ERIE_EERIE_02_IN_MOTION_AUDIO_SINISTER_TEXTURES_VOLUME_2)
	DialogueManager.show_dialogue_balloon(friend_script, "killed")
	await DialogueManager.dialogue_ended
	game_data.player_core_heat = 100.0

func _on_mouse_area_mouse_entered() -> void:
	mouse_in = true
	if p_toggle and not game_data.wpn_equipped  and game_data.suspect_friend:
		CursorManager.set_ponder_mode()


func _on_mouse_area_mouse_exited() -> void:
	mouse_in = false
	if p_toggle and not game_data.wpn_equipped and game_data.suspect_friend:
		CursorManager.set_default_mode()


func _on_mouse_area_interacted() -> void:
	if current_state == State.FOLLOWING:
		DialogueManager.show_dialogue_balloon(friend_script, "start")


func _on_timer_timeout() -> void:
	DialogueManager.show_dialogue_balloon(friend_script, "eldritch_whispers")
	timer.start(randf_range(1, 60))
