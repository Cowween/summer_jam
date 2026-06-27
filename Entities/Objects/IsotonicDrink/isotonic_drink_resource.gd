extends ItemResource
class_name DrinkResource


@export var heat_decrease_amount := 20.0

func use_item() -> void:
	uses -= 1
	GlobalStorage.game_data.player_core_heat -= heat_decrease_amount
	if uses == 0:
		GlobalStorage.game_data.remove_item(self)
