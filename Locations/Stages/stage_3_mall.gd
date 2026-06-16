extends StageManager

@export var grass_temp := 40.0

func _ready() -> void:
	super()
	if not game_data.stage_4_visited:
		if game_data.jacket_on:
			game_data.stage_4_count += 1
		DialogueManager.show_dialogue_balloon(stage_script, "start")

func _on_grass_body_entered(body: Node2D) -> void:
	if not game_data.is_ice_used:
		game_data.add_stage_decrease(-grass_temp, stage_id)


func _on_grass_body_exited(body: Node2D) -> void:
	if not game_data.is_ice_used:
		game_data.add_stage_decrease(grass_temp, stage_id)
