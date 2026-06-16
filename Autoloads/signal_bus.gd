extends Node
class_name SignalBus

signal temperature_changed(temperature: float)
signal player_heat_changed(heat: float)
signal anomaly_pondered(anomaly_id: String, solved: String)
signal anomaly_solved
signal block_player_movement
signal release_player_movement
signal inventory_changed
signal weapon_equipped(item_id: String)
signal refresh_temp
signal aircon_switch_flipped
signal aircon_switch_broken
signal sledge_hammer_swing
signal use_ice
signal friend_sus
signal killed
signal call_pixel_sort
