extends Area2D
class_name Interactable

signal interacted

# Called when the node enters the scene tree for the first time.
@export var interaction : String
const INTERACTIONS := preload("uid://dxbp102mmls3p")



func interact() -> void:
	interacted.emit()
	if interaction != "":
		DialogueManager.show_dialogue_balloon(INTERACTIONS, interaction)
