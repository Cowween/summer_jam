extends Interactable

signal destroyed

func sledge() -> void:
	destroyed.emit()
