extends StageManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	if game_data.is_reset:
		game_data.player_core_heat = 0.0
		game_data.is_reset = false
