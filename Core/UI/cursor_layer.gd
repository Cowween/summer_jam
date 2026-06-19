extends CanvasLayer

# Drag your PNGs into these export slots in the Inspector!
@export var aim_texture: Texture2D
@export var ponder_texture: Texture2D
@export var default_texture: Texture2D # Optional, if you have a normal pointer

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	
	# 3. Listen to your SignalBus for state changes!
	GameBus.weapon_equipped.connect(_on_weapon_equipped)

func _process(_delta: float) -> void:
	# Lock the sprite perfectly to the mouse's position on the screen
	sprite.global_position = sprite.get_viewport().get_mouse_position()

# --- STATE SWAPPERS ---

func set_ponder_mode() -> void:
	sprite.show()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	sprite.texture = ponder_texture
	# Optional: If your ponder cursor is a pointing hand, you might want to 
	# shift the sprite.offset here so the tip of the finger is the exact click point!

func set_aim_mode() -> void:
	sprite.show()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	sprite.texture = aim_texture
	sprite.offset = Vector2.ZERO # Center the crosshair

func set_default_mode() -> void:
	sprite.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# --- SIGNAL LISTENERS ---

func _on_weapon_equipped(weapon_id: String) -> void:
	if weapon_id == "slingshot" or weapon_id == "pistol":
		set_aim_mode()
	else:
		set_default_mode()
