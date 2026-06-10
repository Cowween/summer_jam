extends BaseAnomaly


# Called when the node enters the scene tree for the first time.
func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")
	
func _on_truth_revealed() -> void:
	GlobalStorage.game_data.add_permanent_decrease(5.0)
	$TemperatureArea.monitoring = false

func _on_temperature_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GlobalStorage.game_data.add_stage_decrease(5.0, 1)



func _on_temperature_area_body_exited(body: Node2D) -> void:
	if body is Player:
		GlobalStorage.game_data.add_stage_decrease(-5.0, 1)
