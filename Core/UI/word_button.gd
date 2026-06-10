extends Button
class_name WordButton

var current_parent : HFlowContainer
var thought : HFlowContainer
var words : HFlowContainer

func _on_pressed() -> void:
	if current_parent == words:
		words.remove_child(self)
		thought.add_child(self)
		current_parent = thought
	else:
		thought.remove_child(self)
		words.add_child(self)
		current_parent = words
