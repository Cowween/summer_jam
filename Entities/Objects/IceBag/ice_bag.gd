extends BaseAnomaly

@export var tentacles_attack := 60.0
@export var tentacles_temp := 100.0
@export var ice_bag_dec := 10.0

func solved_interaction() -> void:
	pass

func unsolved_interaction() -> void:
	pass

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass

func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	pass

func clear_tentacles() ->  void:
	$TrueSprite.hide()
	for i in $Tentacles.get_children():
			i.queue_free()

func _on_tentacles_body_entered(body: Node2D) -> void:
	if body is Player:
		data.player_core_heat += tentacles_attack
		data.add_stage_decrease(-tentacles_temp, 2)
	


func _on_tentacles_body_exited(body: Node2D) -> void:
	if body is Player:
		data.add_stage_decrease(tentacles_temp, 2)


func _on_ice_bag_item_picked_up() -> void:
	data.add_permanent_decrease(ice_bag_dec)
