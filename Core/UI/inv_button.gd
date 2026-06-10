extends Button
class_name InvButton

var item_resource : ItemResource

func initialise() -> void:
	if item_resource.uses >= 2:
		text = item_resource.display_name + " x" + str(item_resource.uses)
	else:
		text = item_resource.display_name
func _on_pressed() -> void:
	item_resource.use_item()
	if item_resource.uses >= 2:
		text = item_resource.display_name + " x" + str(item_resource.uses)
	else:
		text = item_resource.display_name
