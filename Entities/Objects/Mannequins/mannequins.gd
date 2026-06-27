extends BaseAnomaly

@export var jacket : ItemResource

@onready var glass: Sprite2D = $Glass
@onready var glass_broken: Sprite2D = $GlassBroken
@onready var naked_texture := preload("res://Assets/Sprites/ClothesShop/clothesnaked.png")

func _ready() -> void:
	super()
	update_visuals()

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")
	await DialogueManager.dialogue_ended
	if data.is_glass_broken and not data.jacket_taken:
		DialogueManager.show_dialogue_balloon(encounter, "jacket")
		await DialogueManager.dialogue_ended
		if data.player_y_n:
			data.jacket_taken = true
			data.add_item(jacket)
			update_visuals()

func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")
	

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass


func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	glitch.hide()
	pass

func update_visuals() -> void:
	glass.hide()
	glass_broken.hide()
	if is_pondered:
		glitch.hide()
	if data.jacket_taken:
		true_sprite.texture = naked_texture
	if data.is_glass_broken:
		glass_broken.show()
	else:
		glass.show()

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
		illusion_sprite.show()
		flicker_timer.stop()
		glitch_sprite.hide()
		glitch.hide()

func _on_interactable_destroyed() -> void:
	if is_pondered and not data.is_glass_broken:
		$Break.play()
		data.is_glass_broken = true
		update_visuals()
		DialogueManager.show_dialogue_balloon(encounter, "glass")
		await DialogueManager.dialogue_ended
	elif not is_pondered:
		DialogueManager.show_dialogue_balloon(encounter, "dont_break")
		await DialogueManager.dialogue_ended

func _on_flicker_timer_timeout() -> void:
	if not glitch: return
	
	# 1. Toggle the glitch sprite on or off
	glitch.visible = not glitch.visible
	glitch_sprite.visible = glitch.visible
	illusion_sprite.visible = not glitch.visible
	
	# 2. Pick a random time for the NEXT toggle
	var next_time: float
	
	if glitch.visible:
		# It's currently VISIBLE. Keep it on screen for a terrifying, split-second flash.
		next_time = randf_range(0.5, 1.0)
	else:
		# It's currently HIDDEN. Wait a few seconds before the next jump scare.
		next_time = randf_range(1.5, 4.0)
		
	# 3. Start the timer again
	flicker_timer.start(next_time)
