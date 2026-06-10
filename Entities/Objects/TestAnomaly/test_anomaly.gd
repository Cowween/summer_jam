extends BaseAnomaly


# Called when the node enters the scene tree for the first time.
func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")
