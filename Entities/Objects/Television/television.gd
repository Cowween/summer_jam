extends BaseAnomaly

@onready var tv_off: Sprite2D = $TvOff
@onready var tv_possessed: AnimatedSprite2D = $TvPosessed
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var shatter : AudioStream
@export var static_sound : AudioStream
var deflect := true

func update_visuals() -> void:
	# 1. Turn EVERYTHING off first so sprites never overlap
	if illusion_sprite: illusion_sprite.visible = false
	if true_sprite: true_sprite.visible = false
	tv_off.visible = false
	tv_possessed.visible = false
	tv_possessed.stop()
	
	# 2. Evaluate state from the final stage (Broken) backward to the first (Off)
	if data.tv_broken:
		# STATE 4: TV is shattered
		
		if true_sprite: true_sprite.visible = true
		glitch_sprite.hide()
		mouse_area.input_pickable = false
		remove_from_group("killable")
		
	elif is_pondered: # is_solved is managed by your base anomaly upon thought success
		# STATE 3: Pondered, possessed, waiting to be shot
		audio_stream_player_2d.stream = static_sound
		audio_stream_player_2d.play()
		tv_possessed.visible = true
		tv_possessed.play("default") # Use the exact name of your animation here
		glitch_sprite.hide()
		mouse_area.input_pickable = true
		deflect = false
		
		
	elif data.tv_on:
		audio_stream_player_2d.stream = static_sound
		audio_stream_player_2d.play()
		# STATE 2: Turned on, hot, but not pondered yet
		if illusion_sprite: illusion_sprite.visible = true
		mouse_area.input_pickable = true
		
	else:
		# STATE 1: TV is off (Default)
		tv_off.visible = true
		mouse_area.input_pickable = false

func _ready() -> void:
	super()
	glitch_sprite = $GlitchSprite
	update_visuals()


func _on_remote_interacted() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "remote")
	await DialogueManager.dialogue_ended
	if data.player_y_n and not data.tv_on:
		data.tv_on = true
		data.add_stage_decrease(-5.0, 1)
		mouse_area.input_pickable = true
		update_visuals()

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")

func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass
	

func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	add_to_group("killable")
	
	update_visuals()
func _on_environment_cooled(current_temp: float) -> void:
	if current_temp <= temperature_unlock_threshold and not is_pondered and data.tv_on:
		# Visual cue that your mind is clear enough to "Ponder" this object
		
		if flicker_timer.is_stopped():

			_on_flicker_timer_timeout()
	elif is_pondered:
		flicker_timer.stop()

	else:
		flicker_timer.stop()
		glitch_sprite.hide()

		
func _on_flicker_timer_timeout() -> void:
	if not glitch_sprite: return
	
	# 1. Toggle the glitch sprite on or off
	glitch_sprite.visible = not glitch_sprite.visible
	
	# 2. Pick a random time for the NEXT toggle
	var next_time: float
	
	if glitch_sprite.visible:
		# It's currently VISIBLE. Keep it on screen for a terrifying, split-second flash.
		next_time = randf_range(1.0, 2.5)
	else:
		# It's currently HIDDEN. Wait a few seconds before the next jump scare.
		next_time = randf_range(1.5, 4.0)
		
	# 3. Start the timer again
	flicker_timer.start(next_time)
func take_slingshot_damage() ->  void:
	if deflect:
		DialogueManager.show_dialogue_balloon(encounter, "deflect")
		return
	audio_stream_player_2d.stream = shatter
	audio_stream_player_2d.play()
	data.tv_broken = true
	data.add_stage_decrease(cooling_reward, 1)
	update_visuals()
	DialogueManager.show_dialogue_balloon(encounter, "fridge")
	await DialogueManager.dialogue_ended
	GameBus.anomaly_solved.emit()
	GameBus.open_fridge.emit()
	data.fridge_open = true
	remove_from_group("killable")
	update_visuals()
	
