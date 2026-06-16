extends StageManager


func _on_god_boss_die() -> void:
	DialogueManager.show_dialogue_balloon(stage_script, "boss_die")
	await DialogueManager.dialogue_ended
