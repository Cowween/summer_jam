extends BaseAnomaly


func solved_interaction() -> void:
	pass

func unsolved_interaction() -> void:
	pass

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass

func random_solution() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "random")

func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	pass
