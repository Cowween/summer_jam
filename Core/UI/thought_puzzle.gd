extends CanvasLayer
class_name ThoughtPuzzle

@export var env : StageManager

@onready var thought := $Panel/Thought
@onready var words := $Panel/Words
@onready var word_button := preload("res://Core/UI/word_button.tscn")
@onready var submit_button := $Panel/ThinkButton

@export var current_puzzle : ThoughtPuzzleResource
@export var whispering : AudioStream
func open_puzzle(puzzle : ThoughtPuzzleResource) -> void:
	current_puzzle = puzzle
	GameBus.block_player_movement.emit()
	SoundManager.play_ui(whispering)
	show()
	
	for child in thought.get_children():
		child.queue_free()
	for child in words.get_children():
		child.queue_free()
	puzzle.initialize_puzzle_arrays()
	var allowed_words: Array[String] = puzzle.high_temp_words.duplicate()
	if env and env.current_temp <= puzzle.unlock_temp:
		allowed_words.append_array(puzzle.low_temp_words)
	allowed_words.shuffle()
	# 2. Spawn them as clickable tiles in the Word Bank
	for word in allowed_words:
		create_word_tile(word, words)
	
func create_word_tile(word: String, container: HFlowContainer):
	var btn := word_button.instantiate()
	btn.text = word
	btn.current_parent = container
	btn.words = words
	btn.thought = thought
	container.add_child(btn)
	
func close_ui() -> void:
	hide()
	SoundManager.stop_ui()
	GameBus.block_player_movement.emit()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	if not env:
		open_puzzle(current_puzzle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_think_button_pressed() -> void:
	var player_sentence : Array[String]
	for btn in thought.get_children():
		if btn is WordButton:
			player_sentence.append(btn.text)
	
	var is_correct := "random"
	for i in current_puzzle.valid_solutions:
		if player_sentence == i:
			is_correct = "correct"
			break
	
	for i in current_puzzle.eldritch_solutions:
		if player_sentence == i:
			is_correct = "wrong"
	
	match is_correct:
		"correct":
			GameBus.anomaly_pondered.emit(current_puzzle.anomaly_id, is_correct)
			close_ui()
			if env:
				DialogueManager.show_dialogue_balloon(current_puzzle.dialogue, "success")
		"wrong":
			GameBus.anomaly_pondered.emit(current_puzzle.anomaly_id, is_correct)

			close_ui()
			if env:
				DialogueManager.show_dialogue_balloon(current_puzzle.dialogue, "failure")
		"random":
			GameBus.anomaly_pondered.emit(current_puzzle.anomaly_id, is_correct)

			close_ui()
			if env:
				DialogueManager.show_dialogue_balloon(current_puzzle.dialogue, "random")
		
			
	
