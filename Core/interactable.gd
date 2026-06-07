extends Area2D
class_name Interactable

signal interacted
# Called when the node enters the scene tree for the first time.
@export var prompt := "Interact"

func interact() -> void:
	interacted.emit()
