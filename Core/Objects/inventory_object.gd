extends StaticBody2D
class_name InventoryObject

@export var item_resource : ItemResource
@onready var interactable : Interactable = $Interactable
@onready var interaction_dialogues : DialogueResource = preload("res://Assets/Text/interactions.dialogue")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_resource.item_id in GlobalStorage.game_data.picked_up_items:
		queue_free()
	interactable.interacted.connect(_on_interacted)


func _on_interacted() -> void:
	GlobalStorage.game_data.picked_up_name = item_resource.display_name + " x" + str(item_resource.uses)
	DialogueManager.show_dialogue_balloon(interaction_dialogues, "item_pick_up")
	GlobalStorage.game_data.add_item(item_resource)
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
