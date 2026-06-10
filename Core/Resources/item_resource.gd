extends Resource
class_name ItemResource

@export var item_id := ""
@export var display_name := ""
@export var uses := 5
@export var item_group := ""
@export_multiline var desc := ""
@export var icon : Texture2D

func use_item() -> void:
	pass
