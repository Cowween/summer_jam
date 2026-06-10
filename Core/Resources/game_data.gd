extends Resource
class_name GameData

var solved_anomalies : Array[String]
var picked_up_items : Array[String]
var inventory : Array[ItemResource]
var item_groups : Array[String]
var is_reset := true
var next_spawn : int = 0
var player_y_n : bool
var picked_up_name : String
var is_inventory_open := true
var is_friend_following := true
var permanent_temp_dec := 0
var stage_temp_dec := [0.0, 0.0, 0.0, 0.0, 0.0]
#==Stage 0 flags==

#==Stage 1 flags==


#==Stage 2 flags==


#==Stage 3 flags==


#==Stage 4 flags==


func register_anomaly_solved(anomaly_id: String):
	if not solved_anomalies.has(anomaly_id):
		solved_anomalies.append(anomaly_id)
		
var player_core_heat: float = 0.0:
	set(value):
		player_core_heat = clamp(value, 0.0, 100.0)
		GameBus.player_heat_changed.emit(player_core_heat)
		
func add_item(item: ItemResource) -> void:
	if not item_groups.has(item.item_group):
		inventory.append(item)
		item_groups.append(item.item_group)
		
	else:
		for i in inventory:
			if i.item_group == item.item_group:
				i.uses += item.uses

	GameBus.inventory_changed.emit()
	picked_up_items.append(item.item_id)
		

func remove_item(item: ItemResource) -> void:
	if inventory.has(item):
		inventory.erase(item)
		item_groups.erase(item.item_group)
		GameBus.inventory_changed.emit()

func has_item(target_id: String) -> bool:
	for item in inventory:
		if item.item_id == target_id:
			return true
	return false

func add_permanent_decrease(amount: float) -> void:
	permanent_temp_dec += amount
	GameBus.refresh_temp.emit()
	
func add_stage_decrease(amount: float, stage_no: int) -> void:
	stage_temp_dec[stage_no] += amount
	GameBus.refresh_temp.emit()
	
	
	
