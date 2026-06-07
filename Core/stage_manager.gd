extends Node
class_name StageManager

@export_enum("following", "stand_still", "distracted") var initial_friend_state : String
@export var spawn : Marker2D
@export var friend_spawn: Marker2D

@onready var player := $Player
@onready var friend := $Friend

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.position = spawn.position
	friend.position = friend_spawn.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
