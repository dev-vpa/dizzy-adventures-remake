extends Node

## Treasure Island gameplay — item use, shop trades, boat win chain.

const TRADE_REWARDS := {
	"video_camera": "dehydrated_boat",
	"cursed_treasure": "outboard_motor",
	"microwave": "petrol",
	"gold_bag": "ignition_key",
}

const BOAT_PARTS := [
	"dehydrated_boat",
	"outboard_motor",
	"petrol",
	"ignition_key",
]


func _ready() -> void:
	Inventory.item_used.connect(_on_item_used)


func _on_item_used(item_id: String) -> void:
	match item_id:
		"snorkel":
			pass
		"salt_spade":
			_try_dig_bubbles()
		"glass_sword":
			_try_open_grave()
		"woodcutters_axe":
			_try_cut_bridge()
		"dynamite", "detonator":
			_try_blast_mine()
		"golden_key":
			_try_open_kitchen()
		"dehydrated_boat", "outboard_motor", "petrol", "ignition_key":
			_try_assemble_boat(item_id)
		_:
			_try_shop_trade(item_id)


func _current_screen_id() -> String:
	return ScreenManager.current_screen_id


func _try_dig_bubbles() -> void:
	if _current_screen_id() != "ocean_bubble_cave":
		return
	if WorldState.get_flag("ocean_bubbles"):
		return
	WorldState.set_flag("ocean_bubbles")
	print("TI: bubbles rise — ↑ to ascend")


func _try_open_grave() -> void:
	if _current_screen_id() != "grave_hill":
		return
	if WorldState.get_flag("grave_open"):
		return
	WorldState.set_flag("grave_open")
	print("TI: grave opened — ↓ into cavern")


func _try_cut_bridge() -> void:
	if _current_screen_id() != "bridge_approach":
		return
	if WorldState.get_flag("bridge_cut"):
		return
	WorldState.set_flag("bridge_cut")
	print("TI: bridge collapses — ↓ into cavern")
	_drop_through_bridge_hole()


func _drop_through_bridge_hole() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	var player := tree.get_first_node_in_group("player") as Node2D
	var world := tree.get_first_node_in_group("game_world")
	if player == null or world == null:
		return
	if player.global_position.x < 180.0 or player.global_position.x > 340.0:
		return
	if world.has_method("request_door_transition"):
		world.call(
			"request_door_transition",
			player,
			"bridge_cavern_west",
			Vector2(256.0, 350.0),
			"up"
		)


func _try_blast_mine() -> void:
	if _current_screen_id() != "mine_blast":
		return
	if WorldState.get_flag("mine_blasted"):
		return
	if not Inventory.has_item("dynamite") or not Inventory.has_item("detonator"):
		print("TI: need dynamite and detonator")
		return
	Inventory.remove_item("dynamite")
	Inventory.remove_item("detonator")
	WorldState.set_flag("mine_blasted")
	print("TI: rocks blasted — ← gold room open")


func _try_open_kitchen() -> void:
	if _current_screen_id() != "cavern_kitchen_door":
		return
	if WorldState.get_flag("kitchen_open"):
		return
	WorldState.set_flag("kitchen_open")
	print("TI: kitchen hatch unlocked — ↓")


func _try_assemble_boat(part_id: String) -> void:
	if _current_screen_id() != "pier_boat":
		return
	var part_index := BOAT_PARTS.find(part_id)
	if part_index < 0:
		return
	if WorldState.get_flag("boat_%s" % part_id):
		return
	for i in range(part_index):
		if not WorldState.get_flag("boat_%s" % BOAT_PARTS[i]):
			print("TI: fit boat parts in order (boat → motor → petrol → key)")
			return
	if not Inventory.has_item(part_id):
		return
	Inventory.remove_item(part_id)
	WorldState.set_flag("boat_%s" % part_id)
	print("TI: boat part fitted — %s" % part_id)
	if _is_boat_complete():
		WorldState.set_flag("boat_ready")
		print("TI: boat ready — talk to Taxman with 30 coins")


func _is_boat_complete() -> bool:
	for part_id in BOAT_PARTS:
		if not WorldState.get_flag("boat_%s" % part_id):
			return false
	return true


func _try_shop_trade(item_id: String) -> void:
	if _current_screen_id() != "shop_interior":
		return
	if not TRADE_REWARDS.has(item_id):
		return
	if not Inventory.has_item(item_id):
		return
	var reward: String = TRADE_REWARDS[item_id]
	var selected := Inventory.get_selected_item()
	if selected != item_id:
		return
	Inventory.try_drop_selected()
	if Inventory.try_pick_up(reward):
		WorldState.set_flag("traded_%s" % item_id)
		print("TI: traded %s for %s" % [item_id, reward])
	else:
		Inventory.try_pick_up(item_id)
