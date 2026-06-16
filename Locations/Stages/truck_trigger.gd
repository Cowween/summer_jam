extends Area2D

@export var stage_script : DialogueResource
var game_data := GlobalStorage.game_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not game_data.is_friend_distracted and not game_data.is_truck_open:
		DialogueManager.show_dialogue_balloon(stage_script, "truck_block")
		await DialogueManager.dialogue_ended
		body.slew_to_position($Marker2D.global_position, 0.5)
