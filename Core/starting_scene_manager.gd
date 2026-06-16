extends StageManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if not game_data.stage_0_visited:
		DialogueManager.show_dialogue_balloon(stage_script, "start")
		game_data.stage_0_visited = true
