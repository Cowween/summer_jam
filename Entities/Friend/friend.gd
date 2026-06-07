extends CharacterBody2D

class_name Friend

enum State { FOLLOWING, STAND_STILL, DISTRACTED }

@export var SPEED: float = 110.0 # Slightly slower or faster than player
@export var STOPPING_DISTANCE: float = 40.0 # Distance to stop behind player
@export var target_node: Node2D = null
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var current_state: State = State.FOLLOWING

var distracted_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass
	
	# Listen to the global signal bus for when anomalies change their behavior
	#SignalBus.anomaly_pondered.connect(_on_anomaly_solved)

func _physics_process(_delta: float) -> void:
	match current_state:
		State.FOLLOWING:
			handle_following_logic()
		State.STAND_STILL:
			velocity = Vector2.ZERO # Do absolutely nothing
		State.DISTRACTED:
			handle_distracted_logic()

	move_and_slide()

func handle_following_logic() -> void:
	if not target_node: return
	
	var distance_to_player = global_position.distance_to(target_node.global_position)

	# Only walk if the player is further away than the stopping comfort zone
	if distance_to_player > STOPPING_DISTANCE:
		nav_agent.target_position = target_node.global_position
		var next_path_pos = nav_agent.get_next_path_position()
		
		# Snappy, instant movement direction calculation
		var direction = global_position.direction_to(next_path_pos).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

func handle_distracted_logic() -> void:
	var distance_to_distraction = global_position.distance_to(distracted_position)
	
	# Walk toward the distracted target position (like the broken AC)
	if distance_to_distraction > 10.0:
		nav_agent.target_position = distracted_position
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO # Arrived at distraction

# Public functions you can trigger via zone triggers or interactions
func set_state(new_state: State) -> void:
	current_state = new_state

func distract_to(global_pos: Vector2) -> void:
	distracted_position = global_pos
	set_state(State.DISTRACTED)
