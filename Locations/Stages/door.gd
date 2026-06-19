extends StaticBody2D

@onready var door: Sprite2D = $Door
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var door_2: Sprite2D = $Door2

func open() -> void:
	door.hide()
	door_2.show()
	collision_shape_2d.set_deferred("disabled", true)
