extends Area2D
class_name SceneTrigger

@export_file("*.tscn") var next_scene : String
@export var next_spawn : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Changing scene")
		GlobalStorage.game_data.next_spawn = next_spawn
		get_tree().change_scene_to_file(next_scene)
