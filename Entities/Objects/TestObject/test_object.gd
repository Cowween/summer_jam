extends StaticBody2D

@export var interactions_script := preload("res://Assets/Text/interactions.dialogue")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_interacted() -> void:
	DialogueManager.show_dialogue_balloon(interactions_script, "test_interaction_1")
