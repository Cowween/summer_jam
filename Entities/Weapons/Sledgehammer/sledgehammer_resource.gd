extends ItemResource

func use_item() -> void:
	GameBus.sledge_hammer_swing.emit()
	
