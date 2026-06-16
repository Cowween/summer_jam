extends Area2D
signal bullet(is_bullet: bool)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_bullet_damage(is_bullet: bool) -> void:
	bullet.emit(is_bullet)
