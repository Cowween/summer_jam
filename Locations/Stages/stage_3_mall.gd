extends StageManager

@export var grass_temp := 40.0
@export var distorted : AudioStream

func _ready() -> void:
	super()
	if game_data.is_ice_used:
		$Park.hide()
		$Parkburnt.show()
	if game_data.is_ice_used:
		SoundManager.bg_music.stream = distorted
		SoundManager.bg_music.play()
	if not game_data.stage_4_visited:
		if game_data.jacket_on:
			game_data.stage_4_count += 1
		DialogueManager.show_dialogue_balloon(stage_script, "start")

func _on_grass_body_entered(body: Node2D) -> void:
	if not game_data.is_ice_used:
		game_data.add_stage_decrease(-grass_temp, stage_id)


func _on_grass_body_exited(body: Node2D) -> void:
	if not game_data.is_ice_used:
		game_data.add_stage_decrease(grass_temp, stage_id)


func _on_fountain_ice_used() -> void:
	var duration :float= SoundManager.bg_music.get_playback_position()
	SoundManager.bg_music.stream = distorted
	SoundManager.bg_music.play(duration)
	$Smoke.smoke()
	$Steam.play()
	await get_tree().create_timer(2.0).timeout
	var tween := create_tween()
	tween.tween_property($Park.material, "shader_parameter/strength", 1.0, 1.0)
	await tween.finished
	$Smoke.no_smoke()
	$Park.hide()
	$Parkburnt.show()
