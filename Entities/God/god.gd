extends Node2D

@export var boss_puzzle: Array[ThoughtPuzzleResource]
@export var thought_puzzle_interface : ThoughtPuzzle
@export var encounter : DialogueResource
@export var heat_damage := 40.0
@export var death_pos : Marker2D
@export var scream1 : AudioStream
@export var psychic : AudioStream

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bob: AnimationPlayer = $Bob
@onready var flash: AnimationPlayer = $Flash
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


@export_group("Arena Bounds")
@export var min_x: float = 100.0
@export var max_x: float = 1000.0
@export var min_y: float = 100.0
@export var max_y: float = 600.0

@export var move_speed: float = 80.0 # Pixels per second
var movement_tween: Tween
# Health & Phases
var slingshot_hits: int = 0
var hits_to_stun: int = 5
var sledgehammer_hits: int = 0
var hits_to_kill: int = 3

var is_stunned: bool = false
var is_dead: bool = false
var psychic_attack := false
var game_data := GlobalStorage.game_data
var off := 30.5
signal boss_die

@onready var slingshot_target: Area2D = $SlingShotTarget
@onready var sledgehammer_target: Area2D = $SledgeHammerTarget
@onready var attack_timer: Timer = $PsychicAttackTimer

func _ready() -> void:
	update_visuals()
	for i in boss_puzzle:
		i.anomaly_id = "boss_psychic_attack"
		i.dialogue = encounter
	sprite.material.set("shader_parameter/flash_modifier", 0.0)
	# Start the psychic attack loop
	attack_timer.timeout.connect(_on_psychic_attack_triggered)
	
	bob.play("bobbing")
	# Listen for when the player successfully escapes the puzzle
	GameBus.anomaly_pondered.connect(_on_puzzle_solved)
	await DialogueManager.dialogue_ended
	attack_timer.start(randf_range(4.0, 7.0))
	start_movement_cycle()

func update_visuals() -> void:
	print("phase change")
	sprite.offset.y = 0
	if is_dead:
		bob.stop()
		sprite.play("default")
		slingshot_target.remove_from_group("shootable")
		sledgehammer_target.remove_from_group("sledge")
	elif is_stunned:
		bob.stop()
		sprite.play("stun")
		sprite.offset.y = off
		point_light_2d.hide()
		slingshot_target.remove_from_group("shootable")
		sledgehammer_target.add_to_group("sledge") # Expose the head!
	elif psychic_attack:
		bob.play("bobbing")
		sprite.play("spin")
	else:
		bob.play("bobbing")
		sprite.play("default")
		point_light_2d.show()
		slingshot_target.add_to_group("shootable") # Absorb rocks!
		sledgehammer_target.remove_from_group("sledge")

func start_movement_cycle() -> void:
	# Don't move if we are knocked down or dead!
	if is_stunned or is_dead: return

	# 1. Pick a random destination inside the arena bounds
	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)
	var target_pos = Vector2(random_x, random_y)

	# 2. Calculate the duration so the boss always moves at a constant speed
	var distance = global_position.distance_to(target_pos)
	var duration = distance / move_speed

	# 3. Create the Tween
	movement_tween = create_tween()
	
	# TRANS_SINE makes the boss gently accelerate and decelerate (eerie floating!)
	movement_tween.set_trans(Tween.TRANS_SINE)
	movement_tween.set_ease(Tween.EASE_IN_OUT)

	# 4. Glide to the target
	movement_tween.tween_property(self, "global_position", target_pos, duration)
	
	# 5. Idle for 1 to 3 seconds at the destination
	movement_tween.tween_interval(randf_range(1.0, 3.0))
	
	# 6. Loop! Call this exact function again to pick a new point
	movement_tween.tween_callback(start_movement_cycle)

func take_bullet_damage(is_bullet: bool) -> void:
	if is_stunned or is_dead or not is_bullet: return
	flash.play("flash")
	slingshot_hits += 1
	print("Boss hit with rock! ", slingshot_hits, "/", hits_to_stun)
	
	if slingshot_hits >= hits_to_stun:
		trigger_stun()

# Your sledgehammer_hitbox.gd should call this when it hits the SledgehammerTarget
func sledge() -> void:
	if not is_stunned or is_dead: return
	flash.play("flash")
	sledgehammer_hits += 1
	print("Boss head smashed! Phase: ", sledgehammer_hits, "/", hits_to_kill)
	
	# Reset for the next phase
	is_stunned = false
	slingshot_hits = 0
	audio_stream_player_2d.stream = scream1
	audio_stream_player_2d.play()
	if sledgehammer_hits >= hits_to_kill:
		trigger_death()
	else:
		# Make it harder! Increase required rocks, or speed up the timer
		sprite.play("stun", -1.2, true)
		
		hits_to_stun += 1 
		await sprite.animation_finished
		start_movement_cycle()
		update_visuals()
		attack_timer.start(randf_range(3.0, 5.0))

func trigger_stun() -> void:
	is_stunned = true
	attack_timer.stop() # Boss can't use UI attacks while knocked down
	if movement_tween: movement_tween.kill()
	update_visuals()
	# Optional: Play a massive roar/crash sound!

func trigger_death() -> void:
	is_dead = true
	if movement_tween: movement_tween.kill()
	attack_timer.stop()
	update_visuals()
	game_data.add_permanent_decrease(60)
	#var tween := create_tween()
	#tween.tween_property(self, "global_position", death_pos.global_position, 2.0)
	#await tween.finished
	sprite.play("spin", 1.4)
	point_light_2d.hide()
	emit_signal("boss_die")
	game_data.friend_killed = false
	game_data.friend_revealed = false
	
func die() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 1.0)
	await tween.finished
	queue_free()

# --- THE PSYCHIC ATTACK ---

func _on_psychic_attack_triggered() -> void:
	if is_stunned or is_dead: return
	psychic_attack = true
	update_visuals()
	audio_stream_player_2d.stream = psychic
	audio_stream_player_2d.play()
	print("BOSS ATTACK: FORCING UI OPEN!")
	
	# Force the puzzle UI to open using your existing global bus
	if boss_puzzle:
		thought_puzzle_interface.open_puzzle(boss_puzzle.pick_random())
		
func _on_puzzle_solved(anomaly_id: String, solved: String) -> void:
	if anomaly_id == "boss_psychic_attack":
		audio_stream_player_2d.stop()
		print("Player escaped the psychic attack!")
		if solved == "wrong" or solved == "random":
			game_data.player_core_heat += 20.0
		psychic_attack = false
		update_visuals()
		# Restart the timer for the next attack
		attack_timer.start(randf_range(4.0, 7.0))


func _on_sling_shot_target_bullet(is_bullet: bool) -> void:
	take_bullet_damage(is_bullet)


func _on_sledge_hammer_target_sledgehammer() -> void:
	sledge()
