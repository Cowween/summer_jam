extends CanvasLayer

@export var env : StageManager
@onready var thermo: AnimatedSprite2D = $Control/MarginContainer/VBoxContainer/HBoxContainer/Margin/Thermo
@onready var temperature: Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/Temperature
@onready var progress_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/HBoxContainer2/ProgressBar


var game_data := GlobalStorage.game_data
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameBus.temperature_changed.connect(_on_temperature_changed)
	GameBus.player_heat_changed.connect(_on_heat_changed)

func update_temp(new_temp: float) -> void:
	if new_temp>game_data.past_temp:
		thermo.play("rise")
	elif new_temp<game_data.past_temp:
		thermo.play("drop")
	game_data.past_temp = new_temp
	temperature.text = str(new_temp)
	await get_tree().create_timer(3.0).timeout
	thermo.play("default")

func update_heat(new_heat: float) -> void:
	progress_bar.value = new_heat
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_temperature_changed(new_temp: float) -> void:
	update_temp(new_temp)


func _on_heat_changed(new_heat: float) -> void:
	update_heat(new_heat)
