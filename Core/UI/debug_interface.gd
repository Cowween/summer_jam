extends CanvasLayer

@export var env : StageManager
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameBus.temperature_changed.connect(_on_temperature_changed)
	GameBus.player_heat_changed.connect(_on_heat_changed)
	$VBoxContainer2/GodMode.button_pressed = GlobalStorage.game_data.god_mode

func update_temp(new_temp: float) -> void:
	$VBoxContainer/Temp.text = "Temp: "+str(new_temp)

func update_heat(new_heat: float) -> void:
	$VBoxContainer/PlayerHeat.text = "PlayerHeat: "+str(new_heat)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_temperature_changed(new_temp: float) -> void:
	update_temp(new_temp)


func _on_heat_changed(new_heat: float) -> void:
	update_heat(new_heat)


func _on_button_pressed() -> void:
	var text : String = $VBoxContainer2/TextEdit.text
	if text != "":
		var value := text.to_float()
		env.current_temp = value
		$VBoxContainer2/TextEdit.clear()


func _on_god_mode_toggled(toggled_on: bool) -> void:
	GlobalStorage.game_data.god_mode = not GlobalStorage.game_data.god_mode
