class_name ThoughtPuzzleResource
extends Resource

@export var dialogue: DialogueResource
@export var anomaly_id: String = ""
@export var unlock_temp := 30.0


@export_multiline var high_temp_text_bank: String = ""
@export_multiline var low_temp_text_bank: String = ""

# TYPE EACH VALID SOLUTION ON A BRAND NEW LINE!
@export_multiline var valid_solution_lines: String = ""
@export_multiline var eldritch_solution_lines: String = ""

# --- RUNTIME DATA LAYERS ---
var high_temp_words: Array[String] = []
var low_temp_words: Array[String] = []

# This now holds an Array of Arrays (a list of all winning combinations)
var valid_solutions: Array = []
var eldritch_solutions: Array = []

func initialize_puzzle_arrays() -> void:
	high_temp_words = _split_words(high_temp_text_bank)
	low_temp_words = _split_words(low_temp_text_bank)
	
	# Clear out old solutions before rebuilding
	valid_solutions.clear()
	eldritch_solutions.clear()
	
	# Split the solution text block line-by-line
	var lines = valid_solution_lines.strip_edges().split("\n", false)
	for line in lines:
		var solution_array = _split_words(line)
		if solution_array.size() > 0:
			valid_solutions.append(solution_array)
	lines = eldritch_solution_lines.strip_edges().split("\n", false)
	for line in lines:
		var solution_array = _split_words(line)
		if solution_array.size() > 0:
			eldritch_solutions.append(solution_array)

func _split_words(input_string: String) -> Array[String]:
	if input_string.strip_edges() == "":
		return []
	
	var raw_split = input_string.strip_edges().split(" ", false)
	var typed_array: Array[String] = []
	for word in raw_split:
		typed_array.append(word)
	return typed_array
