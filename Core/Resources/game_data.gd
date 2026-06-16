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
var loop_count := 0
var friend_killed := false
var friend_revealed := true
var suspect_friend := false
var suspicion_state := 0
var god_mode := false
var current_stage := 0

#==Stage 0 flags==

var stage_0_visited := false

#==Stage 1 flags==

var stage_1_count := 0
var stage_1_friend_count := 0
var stage_1_visited := false
var tv_on := false
var tv_broken := false
var stage_1_solved := false
var fridge_open := false
var friend_seen := false
var friend_killed_reset := true

#==Stage 2 flags==

var stage_2_count := 0
var stage_2_visited := false
var tentacles_cleared := false
var unbroken_lamps := 6
var broken_lamps : Dictionary
var lamps_pondered := false

#==Stage 3 flags==

var stage_3_count := 0
var stage_3_visited := false
var is_truck_open := false
var is_friend_distracted := false
var is_switch_off := false
var is_switch_broken := false
var is_glass_broken := false
var jacket_on := false

#==Stage 4 flags==

var stage_4_count := 0
var stage_4_visited := false
var can_use_ice := false
var is_ice_used := false

func loop() -> void:
	stage_0_visited = false
	stage_1_visited = false
	stage_2_visited = false
	stage_3_visited = false
	stage_4_visited = false
	is_friend_following = false
	is_reset = true
	next_spawn = 0
	loop_count += 1
	player_core_heat = 0.0
	is_reset = false
	print("loop number ", loop_count)

func register_anomaly_solved(anomaly_id: String):
	if not solved_anomalies.has(anomaly_id):
		solved_anomalies.append(anomaly_id)
		GameBus.anomaly_solved.emit()
		
		
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

func remove_item_by_id(target_id: String) -> void:
	for item in inventory:
		if item.item_id == target_id:
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
	
	
	
