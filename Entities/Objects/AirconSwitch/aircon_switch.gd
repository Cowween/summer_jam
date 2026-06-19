extends BaseAnomaly

@onready var aircon_switch_destroyed: Sprite2D = $AirconSwitchDestroyed
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	super()
	update_visuals()

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")

func unsolved_interaction() -> void:
	print("here")
	if data.is_switch_off:
		return
	DialogueManager.show_dialogue_balloon(encounter, "illusion")
	await DialogueManager.dialogue_ended
	if data.player_y_n:
		data.is_switch_off = true
		GameBus.aircon_switch_flipped.emit()
		update_visuals()

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass


func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	pass

func update_visuals() -> void:
	illusion_sprite.hide()
	true_sprite.hide()
	aircon_switch_destroyed.hide()
	
	if data.is_switch_broken:
		aircon_switch_destroyed.show()
		illusion_sprite.show()
		glitch.hide()
	elif is_pondered:
		glitch.hide()
		illusion_sprite.show()
		true_sprite.show()
	elif data.is_switch_off:
		illusion_sprite.show()
		illusion_sprite.frame = 0
	else:
		illusion_sprite.show()
		illusion_sprite.frame = 1

func _on_interactable_destroyed() -> void:
	if is_pondered and not data.is_switch_broken:
		data.is_switch_broken = true
		audio_stream_player_2d.play()
		update_visuals()
		DialogueManager.show_dialogue_balloon(encounter, "break_switch")
		await DialogueManager.dialogue_ended
		GameBus.aircon_switch_broken.emit()
		GameBus.friend_sus.emit()
	else:
		DialogueManager.show_dialogue_balloon(encounter, "dont_break_switch")
		
