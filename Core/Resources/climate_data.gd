extends Resource
class_name ClimateData

signal temperature_changed(new_temp: float)
signal player_heat_changed(new_heat: float)

@export var ambient_temperature: float = 45.0:
	set(value):
		ambient_temperature = clamp(value, -5.0, 100.0)
		temperature_changed.emit(ambient_temperature)
