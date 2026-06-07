extends CharacterBody2D

class_name Player

@export var SPEED: float = 120.0 # Lower speed usually feels better for snappy RPGs

var interacting_area : Interactable = null

func _physics_process(_delta: float) -> void:
	# 1. Get input direction (-1, 0, or 1 for both axes)
	var input_direction: Vector2 = Input.get_vector("leftward", "rightward", "forward", "backward")
	
	# 2. Normalize to prevent fast diagonal walking
	input_direction = input_direction.normalized()

	# 3. CRITICAL: Set velocity directly with NO interpolation (instant start/stop)
	if input_direction != Vector2.ZERO:
		velocity = input_direction * SPEED
	else:
		velocity = Vector2.ZERO # Hard, instant stop

	# 4. Move and handle collisions
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and interacting_area:
		interacting_area.interact()

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Interactable:
		interacting_area = area
		

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is Interactable:
		interacting_area = null
