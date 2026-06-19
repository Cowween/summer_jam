extends BaseAnomaly

@onready var tree_closed: Sprite2D = $TreeClosed
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var cold_enough := false

func _ready() -> void:
	super()
	if is_pondered:
		collision_shape_2d.set_deferred("disabled", true)
		tree_closed.hide()
		true_sprite.hide()

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")

func unsolved_interaction() -> void:
	if cold_enough:
		DialogueManager.show_dialogue_balloon(encounter, "illusion")
	else:
		DialogueManager.show_dialogue_balloon(encounter, "blocking")

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass


func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	collision_shape_2d.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(tree_closed.material, "shader_parameter/strength", 1.0, 1.0)
	true_sprite.hide()
