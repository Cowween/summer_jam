extends BaseAnomaly

@export var lamp_temp := 100.0
@export var lamp_heat := 20.0

@onready var broken_sprite: Sprite2D = $BrokenSprite
@onready var target_area: Area2D = $Target # The area the slingshot rock will actually hit
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var point_light_2d: PointLight2D = $PointLight2D

func _ready() -> void:
	super()
	
	# Forcefully ensure the lamp starts off un-shootable
	if data.broken_lamps.get(name):
		$HeatCircle.monitoring = false
	update_visuals()

func update_visuals() -> void:
	# 1. Hide everything first to prevent overlapping
	if illusion_sprite: illusion_sprite.visible = false
	if true_sprite: true_sprite.visible = false
	if broken_sprite: broken_sprite.visible = false
	
	# 2. Evaluate from the final state (Broken) backwards
	if data.broken_lamps.get(name): # Make sure to add 'lamp_broken' to your game_data.gd!
		# STATE 3: The eye was shot and shattered
		if broken_sprite: broken_sprite.visible = true
		glitch.hide()
		point_light_2d.hide()

		
	elif data.lamps_pondered: 
		# STATE 2: The puzzle was solved, the eye is revealed and ready to be shot
		if true_sprite: true_sprite.visible = true
		target_area.deflect = false
		glitch.hide()
		
	else:
		# STATE 1: Normal street lamp (Illusion)
		if illusion_sprite: illusion_sprite.visible = true
		mouse_area.input_pickable = true


func unsolved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "illusion")

func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes if the player fails the puzzle
	pass


func _on_truth_revealed() -> void:
	# This triggers when the Duolingo puzzle is successfully completed
	
	# 1. Add BOTH the root and the target to the killable group so the rock detects it
	data.lamps_pondered = true
		
	# 2. Switch to the TrueSprite (The Eye)
	update_visuals()


# Hook this up to the Target node's area_entered/body_entered signal if you haven't already!
func _on_target_shot() -> void:
	# Only execute if it's actually killable (prevents accidental sequence breaking)
	if target_area.deflect:
		return
	# 1. Update the permanent save data
	data.unbroken_lamps -= 1
	data.broken_lamps[name] = true
	$HeatCircle.monitoring = false
	audio_stream_player_2d.play()
	if data.unbroken_lamps == 0:
		data.add_stage_decrease(cooling_reward, 2)
		GameBus.anomaly_solved.emit()
	
	# 2. Make it un-shootable so the player can't keep hitting it
	remove_from_group("killable")
	if target_area:
		target_area.remove_from_group("killable")
		
	# 3. Switch to the BrokenSprite
	update_visuals()
	

func _on_heat_circle_body_entered(body: Node2D) -> void:
	if body is Player:
		data.add_stage_decrease(-lamp_temp, 2)
		data.player_core_heat += lamp_heat
		
func _on_heat_circle_body_exited(body: Node2D) -> void:
	if body is Player:
		data.add_stage_decrease(lamp_temp, 2)
