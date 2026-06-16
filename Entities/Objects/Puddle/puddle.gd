extends Interactable

@export var cooling := 5.0
@export var interactions := preload("res://Assets/Text/interactions.dialogue")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	GlobalStorage.game_data.add_stage_decrease(cooling, 2)


func _on_body_exited(body: Node2D) -> void:
	GlobalStorage.game_data.add_stage_decrease(-cooling, 2)


func _on_interacted() -> void:
	DialogueManager.show_dialogue_balloon(interactions, "puddle")
