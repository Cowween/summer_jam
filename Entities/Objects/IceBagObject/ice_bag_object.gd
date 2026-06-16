extends ItemResource

	
func use_item() -> void:
	if GlobalStorage.game_data.can_use_ice:
		GameBus.use_ice.emit()
		GlobalStorage.game_data.remove_item(self)
