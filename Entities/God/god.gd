extends Node2D

@export var boss_puzzle: Array[ThoughtPuzzleResource]
@export var thought_puzzle_interface : ThoughtPuzzle
@export var encounter : DialogueResource

# Health & Phases
var slingshot_hits: int = 0
var hits_to_stun: int = 10
var sledgehammer_hits: int = 0
var hits_to_kill: int = 3

var is_stunned: bool = false
var is_dead: bool = false
var psychic_attack := false
var game_data := GlobalStorage.game_data

signal boss_die

@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var stunned_sprite: Sprite2D = $StunnedSprite
@onready var psychic_sprite: Sprite2D = $GodPsychic

@onready var slingshot_target: Area2D = $SlingShotTarget
@onready var sledgehammer_target: Area2D = $SledgeHammerTarget
@onready var attack_timer: Timer = $PsychicAttackTimer

func _ready() -> void:
	update_visuals()
	
	for i in boss_puzzle:
		i.anomaly_id = "boss_psychic_attack"
		i.dialogue = encounter
	# Start the psychic attack loop
	attack_timer.timeout.connect(_on_psychic_attack_triggered)
	attack_timer.start(randf_range(4.0, 7.0))
	
	# Listen for when the player successfully escapes the puzzle
	GameBus.anomaly_pondered.connect(_on_puzzle_solved)

func update_visuals() -> void:
	idle_sprite.visible = false
	stunned_sprite.visible = false
	psychic_sprite.visible = false
	print("phase change")
	if is_dead:
		stunned_sprite.visible = true
		slingshot_target.remove_from_group("shootable")
		sledgehammer_target.remove_from_group("sledge")
	elif is_stunned:
		stunned_sprite.visible = true
		slingshot_target.remove_from_group("shootable")
		sledgehammer_target.add_to_group("sledge") # Expose the head!
	elif psychic_attack:
		psychic_sprite.visible = true
	else:
		
		idle_sprite.visible = true
		slingshot_target.add_to_group("shootable") # Absorb rocks!
		sledgehammer_target.remove_from_group("sledge")


func take_bullet_damage(is_bullet: bool) -> void:
	if is_stunned or is_dead or not is_bullet: return
	
	slingshot_hits += 1
	print("Boss hit with rock! ", slingshot_hits, "/", hits_to_stun)
	
	if slingshot_hits >= hits_to_stun:
		trigger_stun()

# Your sledgehammer_hitbox.gd should call this when it hits the SledgehammerTarget
func sledge() -> void:
	if not is_stunned or is_dead: return
	
	sledgehammer_hits += 1
	print("Boss head smashed! Phase: ", sledgehammer_hits, "/", hits_to_kill)
	
	# Reset for the next phase
	is_stunned = false
	slingshot_hits = 0
	
	if sledgehammer_hits >= hits_to_kill:
		trigger_death()
	else:
		# Make it harder! Increase required rocks, or speed up the timer
		hits_to_stun += 1 
		update_visuals()
		attack_timer.start(randf_range(3.0, 5.0))

func trigger_stun() -> void:
	is_stunned = true
	attack_timer.stop() # Boss can't use UI attacks while knocked down
	update_visuals()
	# Optional: Play a massive roar/crash sound!

func trigger_death() -> void:
	is_dead = true
	attack_timer.stop()
	update_visuals()
	game_data.add_permanent_decrease(60)
	emit_signal("boss_die")
	game_data.friend_killed = false
	game_data.friend_revealed = false
	
	

# --- THE PSYCHIC ATTACK ---

func _on_psychic_attack_triggered() -> void:
	if is_stunned or is_dead: return
	psychic_attack = true
	update_visuals()
	print("BOSS ATTACK: FORCING UI OPEN!")
	
	# Force the puzzle UI to open using your existing global bus
	if boss_puzzle:
		thought_puzzle_interface.open_puzzle(boss_puzzle.pick_random())
		
func _on_puzzle_solved(anomaly_id: String, solved: String) -> void:
	if anomaly_id == "boss_psychic_attack":
		print("Player escaped the psychic attack!")
		psychic_attack = false
		update_visuals()
		# Restart the timer for the next attack
		attack_timer.start(randf_range(4.0, 7.0))


func _on_sling_shot_target_bullet(is_bullet: bool) -> void:
	take_bullet_damage(is_bullet)


func _on_sledge_hammer_target_sledgehammer() -> void:
	sledge()
