extends CanvasLayer
class_name InventoryInteraface

@export var inv_button : PackedScene

@onready var inventory := $ScrollContainer/VBoxContainer

var game_data : GameData = GlobalStorage.game_data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameBus.inventory_changed.connect(_on_inventory_changed)
	for i in inventory.get_children():
		i.queue_free()

func show_inventory() -> void:
	show()
	_update_inventory()

func hide_inventory() -> void:
	hide()

func _update_inventory() -> void:
	for i in inventory.get_children():
		i.queue_free()
	for item in game_data.inventory:
		var new_btn : InvButton = inv_button.instantiate()
		new_btn.item_resource = item
		new_btn.initialise()
		#new_btn.pressed.connect(_on_inventory_changed)
		inventory.add_child(new_btn)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_inventory_changed() -> void:
	_update_inventory()
