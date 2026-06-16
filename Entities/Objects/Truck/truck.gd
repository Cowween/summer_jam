extends StaticBody2D

var game_data := GlobalStorage.game_data
@onready var truck: Sprite2D = $Truck
@onready var truck_open: Sprite2D = $TruckOpen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game_data.is_truck_open:
		truck.hide()
		truck_open.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactable_interacted() -> void:
	if game_data.is_truck_open or not game_data.is_friend_distracted:
		return
	
	game_data.is_truck_open = true
	truck.hide()
	truck_open.show()
