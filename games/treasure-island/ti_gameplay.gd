extends Node

## Treasure Island gameplay — item use and shop trade stubs.

const TRADE_REWARDS := {
	"video_camera": "dehydrated_boat",
	"cursed_treasure": "outboard_motor",
	"microwave": "petrol",
	"gold_bag": "ignition_key",
}


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
	WorldState.set_flag("boat_%s" % part_id)
	print("TI: boat part fitted — %s" % part_id)


func _try_shop_trade(item_id: String) -> void:
	if _current_screen_id() != "shop_interior":
		return
	if not TRADE_REWARDS.has(item_id):
		return
	if not Inventory.has_item(item_id):
		return
	var reward: String = TRADE_REWARDS[item_id]
	# Drop traded item from inventory, then grant reward if space.
	var selected := Inventory.get_selected_item()
	if selected != item_id:
		return
	Inventory.try_drop_selected()
	if Inventory.try_pick_up(reward):
		WorldState.set_flag("traded_%s" % item_id)
		print("TI: traded %s for %s" % [item_id, reward])
	else:
		# Restore if inventory full after drop (shouldn't happen with 3 slots).
		Inventory.try_pick_up(item_id)
