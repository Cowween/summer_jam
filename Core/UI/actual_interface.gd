extends CanvasLayer

@export var env : StageManager
@onready var thermo: AnimatedSprite2D = $Control/MarginContainer/VBoxContainer/HBoxContainer/Margin/Thermo
@onready var temperature: Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/Temperature
@onready var progress_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/HBoxContainer2/ProgressBar
@onready var cold: ColorRect = $Control/Cold
@onready var hot: ColorRect = $Control/Hot


var game_data := GlobalStorage.game_data
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameBus.temperature_changed.connect(_on_temperature_changed)
	GameBus.player_heat_changed.connect(_on_heat_changed)

func update_temp(new_temp: float) -> void:
	if new_temp>game_data.past_temp:
		thermo.play("rise")
		flash(hot)
	elif new_temp<game_data.past_temp:
		thermo.play("drop")
		flash(cold)
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

func flash(thing: ColorRect) -> void:
	thing.show()
	
	var tween := create_tween()
	
	# 1. Fade in
	tween.tween_property(thing, "color:a", 0.3, 0.5)
	
	# 2. Fade out (Automatically waits for step 1 to finish!)
	tween.tween_property(thing, "color:a", 0.0, 0.5)
	
	# 3. Hide the node (Automatically waits for step 2 to finish!)
	tween.tween_callback(thing.hide)
