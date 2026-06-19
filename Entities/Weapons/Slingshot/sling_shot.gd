extends InventoryObject


func _on_interacted() -> void:
	GlobalStorage.game_data.picked_up_name = item_resource.display_name + " x" + str(item_resource.uses)
	DialogueManager.show_dialogue_balloon(interaction_dialogues, "slingshot_pickup")
	GlobalStorage.game_data.add_item(item_resource)
	hide()
	await DialogueManager.dialogue_ended
	picked_up.emit()
	queue_free()
