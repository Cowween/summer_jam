extends Node2D


func smoke() -> void:
	for i in get_children():
		i.emitting = true

func no_smoke() -> void:
	for i in get_children():
		i.emitting = false
