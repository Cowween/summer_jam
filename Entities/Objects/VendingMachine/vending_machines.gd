extends BaseAnomaly

@export var coffee_ice : ItemResource
@export var hot_drink : ItemResource
@export var interactions := preload("res://Assets/Text/interactions.dialogue")


func solved_interaction() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "truth")

func unsolved_interaction() -> void:
	if data.picked_up_items.has(hot_drink.item_id):
		DialogueManager.show_dialogue_balloon(encounter, "drink_over")
		return
	DialogueManager.show_dialogue_balloon(encounter, "illusion")
	await DialogueManager.dialogue_ended
	if not data.player_y_n:
		return
	data.picked_up_name = hot_drink.display_name + " x" + str(hot_drink.uses)
	DialogueManager.show_dialogue_balloon(interactions, "item_pick_up")
	data.add_item(hot_drink)

func execute_hallucination_trap() -> void:
	# Virtual function: Handles heat spikes, or misleading text from the friend
	pass

func random_solution() -> void:
	DialogueManager.show_dialogue_balloon(encounter, "random")

func _on_truth_revealed() -> void:
	# Virtual function: Overridden by individual anomalies (e.g., breaking streetlights)
	data.add_stage_decrease(cooling_reward, 2)
	pass


func _on_coffee_machine_interacted() -> void:
	if data.picked_up_items.has(coffee_ice.item_id):
		DialogueManager.show_dialogue_balloon(encounter, "coffee_over")
		return
	DialogueManager.show_dialogue_balloon(encounter, "get_coffee")
	await DialogueManager.dialogue_ended
	if not data.player_y_n:
		return
	data.picked_up_name = coffee_ice.display_name + " x" + str(coffee_ice.uses)
	DialogueManager.show_dialogue_balloon(interactions, "item_pick_up")
	data.add_item(coffee_ice)
