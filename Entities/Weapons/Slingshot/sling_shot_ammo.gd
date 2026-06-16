extends Area2D
class_name SlingshotAmmo

@export var speed: float = 600.0

# The player script will give us this direction when it spawns us
var direction: Vector2 = Vector2.ZERO 
var is_pistol := false

func _ready() -> void:
	# Destroy the projectile automatically after 2 seconds so it doesn't fly forever
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Move in a straight line forever
	position += direction * speed * delta

# Connect the body_entered signal via the Inspector!
func _on_body_entered(body: Node2D) -> void:
	# Example: If it hits a demonic street lamp, trigger its blind effect!
	if body.is_in_group("killable"):
		body.take_slingshot_damage()
		if body.deflect:
			direction.y = -direction.y
		else:
			queue_free()
	elif body.is_in_group("shootable"):
		if is_pistol:
			body.take_bullet_damage(is_pistol)
			queue_free()
		else:
			direction.y = -direction.y
			body.take_bullet_damage(is_pistol)

	
	# Destroy the ammo when it hits a wall or target
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("killable"):
		area.take_slingshot_damage()
		if area.deflect:
			direction.y = -direction.y
		else:
			queue_free()
	elif area.is_in_group("shootable"):
		if is_pistol:
			area.take_bullet_damage(is_pistol)
			queue_free()
		else:
			direction.y = -direction.y
			area.take_bullet_damage(is_pistol)
		
			
