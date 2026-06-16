extends BaseAnomaly

func _ready() -> void:
	super()
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
	pass


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player and is_pondered:
		data.can_use_ice = true


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player and is_pondered:
		data.can_use_ice = false

func _on_ice_used() -> void:
	data.add_stage_decrease(cooling_reward, 3)
	data.is_ice_used = true
	DialogueManager.show_dialogue_balloon(encounter, "use_ice")
	
