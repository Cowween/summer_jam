extends InventoryObject

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_resource.item_id in GlobalStorage.game_data.picked_up_items:
		interactable.monitorable = false
	interactable.interacted.connect(_on_interacted)


func _on_interacted() -> void:
	if not GlobalStorage.game_data.fridge_open:
		DialogueManager.show_dialogue_balloon(interaction_dialogues, "fridge_locked")
		return
	if item_resource.item_id in GlobalStorage.game_data.picked_up_items:
		return
	DialogueManager.show_dialogue_balloon(interaction_dialogues, "fridge")
	await DialogueManager.dialogue_ended
	if not GlobalStorage.game_data.player_y_n:
		return
	GlobalStorage.game_data.picked_up_name = item_resource.display_name + " x" + str(item_resource.uses)
	DialogueManager.show_dialogue_balloon(interaction_dialogues, "item_pick_up")
	GlobalStorage.game_data.add_item(item_resource)
	interactable.monitorable = false
