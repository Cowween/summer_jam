extends ItemResource

func use_item() -> void:
	GameBus.weapon_equipped.emit(item_id)
	
