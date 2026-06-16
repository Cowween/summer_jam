extends ItemResource

@export var temp_decrease_amount := 10.0

func use_item() -> void:
	GlobalStorage.game_data.add_permanent_decrease(temp_decrease_amount)
	GlobalStorage.game_data.remove_item(self)
		
