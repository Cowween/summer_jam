extends BaseAnomaly

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var smoke: GPUParticles2D = $Smoke
@onready var smoke_2: GPUParticles2D = $Smoke2
@onready var fountainevil: Sprite2D = $Fountainevil
@onready var scream: AudioStreamPlayer2D = $Scream

signal ice_used

func _ready() -> void:
	super()
	if is_pondered:
		gpu_particles_2d.emitting = true
		if not data.is_ice_used:
			smoke.emitting = true
		else:
			fountainevil.show()
			smoke.emitting = false
	GameBus.use_ice.connect(_on_ice_used)

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")

func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass


func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	smoke.emitting = true
	gpu_particles_2d.emitting = true
	glitch.hide()


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player and is_pondered:
		data.can_use_ice = true


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player and is_pondered:
		data.can_use_ice = false

func _on_ice_used() -> void:
	scream.play()
	data.add_stage_decrease(cooling_reward, 3)
	data.is_ice_used = true
	smoke.emitting = false
	emit_signal("ice_used")
	DialogueManager.show_dialogue_balloon(encounter, "use_ice")
	smoke_2.emitting = true
	await get_tree().create_timer(2.0).timeout
	fountainevil.show()
	await get_tree().create_timer(2.0).timeout
	smoke_2.emitting = false
	
	
