extends BaseAnomaly

@export var jacket : ItemResource

@onready var glass: Sprite2D = $Glass
@onready var glass_broken: Sprite2D = $GlassBroken

func _ready() -> void:
	super()
	update_visuals()

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")
	await DialogueManager.dialogue_ended
	if data.is_glass_broken:
		DialogueManager.show_dialogue_balloon(encounter, "jacket")
		await DialogueManager.dialogue_ended
		if data.player_y_n:
			data.add_item(jacket)

func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")
	

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass


func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	pass

func update_visuals() -> void:
	glass.hide()
	glass_broken.hide()
	
	if data.is_glass_broken:
		glass_broken.show()
	else:
		glass.show()
		

func _on_interactable_destroyed() -> void:
	if is_pondered and not data.is_glass_broken:
		data.is_glass_broken = true
		update_visuals()
		DialogueManager.show_dialogue_balloon(encounter, "glass")
		await DialogueManager.dialogue_ended
