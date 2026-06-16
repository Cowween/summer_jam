class_name BaseAnomaly
extends Node2D

@export var anomaly_id: String = ""
@export var temperature_unlock_threshold: float = 30.0
@export var cooling_reward: float = 5.0
@export var world : StageManager
@export var encounter : DialogueResource
@export var thought_puzzle_interface : ThoughtPuzzle
@export var thought_puzzle: ThoughtPuzzleResource

@onready var interactable: Interactable = $Interactable
@onready var illusion_sprite: CanvasItem = $IllusionSprite
@onready var true_sprite: CanvasItem = $TrueSprite
@onready var glitch_sprite : CanvasItem = $TrueSprite
@onready var mouse_area : Area2D = $MouseArea
@onready var glitch: CanvasItem = $Glitch

# Fetching the data architecture from our global anchor point
@onready var data: GameData = GlobalStorage.game_data

var is_pondered: bool = false
var mouse_in := false
var is_input_locked := false
var flicker_timer: Timer


func _ready() -> void:
	#Connect signals
	interactable.interacted.connect(_on_interact)
	mouse_area.mouse_entered.connect(_on_mouse_entered)
	mouse_area.mouse_exited.connect(_on_mouse_exited)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	GameBus.temperature_changed.connect(_on_environment_cooled)
	GameBus.anomaly_pondered.connect(_on_anomaly_pondered)
	flicker_timer = Timer.new()
	flicker_timer.one_shot = true
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	add_child(flicker_timer)
	
	if thought_puzzle:
		thought_puzzle.dialogue = encounter
		thought_puzzle.anomaly_id = anomaly_id
		thought_puzzle.unlock_temp = temperature_unlock_threshold
	# Evaluate status instantly on spawn/load
	evaluate_anomaly_state()

func evaluate_anomaly_state() -> void:
	if data.solved_anomalies.has(anomaly_id):
		is_pondered = true
		illusion_sprite.visible = false
		true_sprite.visible = true
		
	else:
		illusion_sprite.visible = true
		true_sprite.visible = false

func cold_visuals() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ponder") and mouse_in and not is_pondered:
		_ponder()

func _ponder() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "ponder_intro")
	await DialogueManager.dialogue_ended
	
	if data.player_y_n:
		thought_puzzle_interface.open_puzzle(thought_puzzle)

func _on_environment_cooled(current_temp: float) -> void:
	if current_temp <= temperature_unlock_threshold and not is_pondered:
		# Visual cue that your mind is clear enough to "Ponder" this object
		cold_visuals()
		if flicker_timer.is_stopped():
			_on_flicker_timer_timeout()
	elif is_pondered:
		flicker_timer.stop()
		glitch.hide()
	else:
		flicker_timer.stop()
		glitch_sprite.hide()
		glitch.hide()

func _on_interact() -> void:
	if is_pondered:
		solved_interaction()
	else:
		unsolved_interaction()

func _on_mouse_entered():
	print("mouse in")
	mouse_in = true
	
func _on_mouse_exited():
	mouse_in = false
	
func _on_dialogue_started(_resource: DialogueResource) -> void:
	is_input_locked = true
	
func _on_dialogue_ended(_resource: DialogueResource) -> void:
	is_input_locked = false


func ponder_and_reveal() -> void:
	is_pondered = true
	illusion_sprite.visible = false
	true_sprite.visible = true
	flicker_timer.stop()
	# Mutate state in our resources
	data.register_anomaly_solved(anomaly_id)
	
	
	_on_truth_revealed() # Custom code hooks for child scenes

func solved_interaction() -> void:
	pass

func unsolved_interaction() -> void:
	pass

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass

func random_solution() -> void:
	pass

func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	pass

func _on_anomaly_pondered(solved_anomaly_id: String, solved: String) -> void:
	if anomaly_id == solved_anomaly_id:
		match solved:
			"correct":
				ponder_and_reveal()
			"wrong":
				execute_hallucination_trap()
			"random":
				random_solution()

func _on_flicker_timer_timeout() -> void:
	if not glitch: return
	
	# 1. Toggle the glitch sprite on or off
	glitch.visible = not glitch.visible
	glitch_sprite.visible = glitch.visible
	
	# 2. Pick a random time for the NEXT toggle
	var next_time: float
	
	if glitch.visible:
		# It's currently VISIBLE. Keep it on screen for a terrifying, split-second flash.
		next_time = randf_range(1.0, 2.5)
	else:
		# It's currently HIDDEN. Wait a few seconds before the next jump scare.
		next_time = randf_range(1.5, 4.0)
		
	# 3. Start the timer again
	flicker_timer.start(next_time)
