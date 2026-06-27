extends InventoryObject

const KITCHENOPEN = preload("uid://copcm0oowj2y")
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameBus.open_fridge.connect(_on_open_fridge)
	if GlobalStorage.game_data.fridge_open:
		sprite_2d.texture = KITCHENOPEN
	interactable.interacted.connect(_on_interacted)


func _on_interacted() -> void:
	if not GlobalStorage.game_data.fridge_open:
		DialogueManager.show_dialogue_balloon(interaction_dialogues, "fridge_locked")
		return
	var item := item_resource.duplicate()
	var uses := 0
	for i in GlobalStorage.game_data.inventory:
		if i.item_id == item.item_id:
			uses = i.uses
			if i.uses == 5:
				DialogueManager.show_dialogue_balloon(interaction_dialogues, "cannot_carry")
				await DialogueManager.dialogue_ended
				return
			else:
				break
	DialogueManager.show_dialogue_balloon(interaction_dialogues, "fridge")
	await DialogueManager.dialogue_ended
	if not GlobalStorage.game_data.player_y_n:
		return
	GlobalStorage.game_data.picked_up_name = item_resource.display_name + " x" + str(5-uses)
	DialogueManager.show_dialogue_balloon(interaction_dialogues, "item_pick_up")
	GlobalStorage.game_data.add_item(item)

func _on_open_fridge() -> void:
	sprite_2d.texture = KITCHENOPEN
