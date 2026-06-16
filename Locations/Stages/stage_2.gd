extends StageManager

@export var aircon_temp := 40.0
@onready var switch_pos: Marker2D = $SwitchPos
@onready var aircon_switch: StaticBody2D = $Anomalies/AirconSwitch

func _ready() -> void:
	super()
	GameBus.aircon_switch_flipped.connect(_on_switch_flipped)
	GameBus.aircon_switch_broken.connect(_on_switch_broken)
	if not game_data.stage_2_visited:
		DialogueManager.show_dialogue_balloon(stage_script, "start")
		await DialogueManager.dialogue_ended
		game_data.stage_2_visited = true
		game_data.stage_2_count += 1


func _on_aircon_area_body_entered(body: Node2D) -> void:
	if body is not Player or game_data.is_truck_open:
		return
	game_data.add_stage_decrease(-aircon_temp, stage_id)


func _on_aircon_area_body_exited(body: Node2D) -> void:
	if body is not Player or game_data.is_truck_open:
		return
	game_data.add_stage_decrease(aircon_temp, stage_id)

func _on_switch_flipped() -> void:
	friend.distract_to(switch_pos.global_position)
	game_data.is_friend_distracted = true
	game_data.is_friend_following = false
	await friend.arrived
	game_data.is_switch_off = false
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
