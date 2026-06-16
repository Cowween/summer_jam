extends ItemResource

@export var jacket_cooling := 20.0

func use_item() -> void:
	GlobalStorage.game_data.add_permanent_decrease(jacket_cooling)
	GlobalStorage.game_data.remove_item(self)
	GlobalStorage.game_data.jacket_on = true
