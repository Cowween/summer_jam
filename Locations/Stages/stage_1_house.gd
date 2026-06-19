extends StageManager

@export var knocking : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if game_data.stage_1_solved and game_data.friend_seen:
		$Door.open()
		$Triggers/SceneTrigger2.monitoring = true
	if not game_data.stage_1_visited:
		game_data.stage_1_visited = true
		if game_data.stage_1_solved:
			friend.global_position = spawn_list[1].get_node("FriendSpawn").global_position
			friend.set_state(Friend.State.STAND_STILL)
		DialogueManager.show_dialogue_balloon(stage_script, "start")
		await DialogueManager.dialogue_ended
		game_data.stage_1_count += 1
		if game_data.stage_1_solved:
			friend.set_state(Friend.State.FOLLOWING)
			game_data.stage_1_friend_count += 1
			
	
	

func _on_anomaly_solved() -> void:
	if game_data.solved_anomalies.has("calendar") and game_data.tv_broken:
		game_data.stage_1_solved = true
		SoundManager.play_sfx(knocking)
		DialogueManager.show_dialogue_balloon(stage_script, "puzzles_solved")


func _on_door_interacted() -> void:
	if not game_data.stage_1_solved:
		DialogueManager.show_dialogue_balloon(stage_script, "hot_door")
		return
	if not game_data.friend_seen:
		$Door.open()
		player.slew_to_position(spawn_list[1].get_node("Spawn").global_position, 0.2)
		friend.global_position = spawn_list[1].get_node("FriendSpawn").global_position
		friend.current_state = friend.State.STAND_STILL
		DialogueManager.show_dialogue_balloon(stage_script, "friend")
		await DialogueManager.dialogue_ended
		set_friend_state("following")
		game_data.is_friend_following = true
		game_data.friend_seen = true
		$Triggers/SceneTrigger2.monitoring = true

		


func _on_text_interacted() -> void:
	DialogueManager.show_dialogue_balloon(stage_script, "tv_text")
