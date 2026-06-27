extends StageManager

@export var aircon_temp := 40.0
@export var switch : AudioStream
@onready var switch_pos: Marker2D = $SwitchPos
@onready var aircon_switch: StaticBody2D = $Anomalies/AirconSwitch
const DEEZNATSU_ROADLOOPDISTORTED = preload("uid://bt76b5s6d6cf7")

func _ready() -> void:
	super()
	
	GameBus.aircon_switch_flipped.connect(_on_switch_flipped)
	GameBus.aircon_switch_broken.connect(_on_switch_broken)
	GameBus.truck.connect(func(): ac_toggle(true))
	if game_data.friend_revealed:
		SoundManager.play_bg(DEEZNATSU_ROADLOOPDISTORTED)
	if not game_data.stage_2_visited:
		DialogueManager.show_dialogue_balloon(stage_script, "start")
		await DialogueManager.dialogue_ended
		game_data.stage_2_visited = true
		game_data.stage_2_count += 1
	if game_data.is_friend_distracted:
		friend.global_position = switch_pos.global_position
	if game_data.is_truck_open:
		ac_toggle(true)


func _on_aircon_area_body_entered(body: Node2D) -> void:
	if body is not Player or game_data.is_truck_open:
		return
	game_data.add_stage_decrease(-aircon_temp, stage_id)


func _on_aircon_area_body_exited(body: Node2D) -> void:
	if body is not Player or game_data.is_truck_open:
		return
	
	game_data.add_stage_decrease(aircon_temp, stage_id)
func ac_toggle(off := false) -> void:
	if off:
		for i in $ACParticles.get_children():
			i.emitting = false
		return
	for i in $ACParticles.get_children():
		i.emitting = not i.emitting
func _on_switch_flipped() -> void:
	ac_toggle()
	SoundManager.play_sfx(switch)
	await get_tree().create_timer(2.0).timeout
	friend.distract_to(switch_pos.global_position)
	game_data.is_friend_distracted = true
	game_data.is_friend_following = false
	
	await friend.arrived
	SoundManager.play_sfx(switch)
	game_data.is_switch_off = false
	ac_toggle()
	aircon_switch.update_visuals()
	friend.set_state(Friend.State.FOLLOWING)
	
func _on_switch_broken() -> void:
	friend.distract_to(switch_pos.global_position)
	game_data.is_friend_distracted = true
	game_data.is_friend_following = false


func _on_stage_transition_body_entered(body: Node2D) -> void:
	if game_data.current_stage == 2:
		game_data.current_stage = 3
		if not game_data.stage_3_visited:
			DialogueManager.show_dialogue_balloon(stage_script, "stage_transition")
			await DialogueManager.dialogue_ended
			game_data.stage_3_visited = true
			game_data.stage_3_count += 1
			if game_data.is_switch_broken:
				_on_switch_broken()
			
	else:
		game_data.current_stage = 2
