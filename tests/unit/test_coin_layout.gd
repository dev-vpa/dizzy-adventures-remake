class_name TestCoinLayout
extends RefCounted

## Exactly 30 unique world coins on TI levels, matching coin_map screens.

const TestAssert := preload("res://tests/test_assert.gd")
const LevelRegistryHelper := preload("res://tests/helpers/level_registry_helper.gd")
const TiItems := preload("res://games/treasure-island/ti_items.gd")

const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")


static func run() -> void:
	var levels_path: String = TI_CONFIG.levels_path
	var world_ids: Dictionary = {}
	var coin_count := 0
	for screen_id in LevelRegistryHelper.list_screen_ids(levels_path):
		var path := levels_path.path_join("%s.tscn" % screen_id)
		var packed: PackedScene = load(path)
		if packed == null:
			continue
		var root: Node = packed.instantiate()
		coin_count += _count_coins(root, screen_id, world_ids)
		root.free()
	TestAssert.eq(coin_count, 30, "exactly 30 coin pickups in levels (got %d)" % coin_count)
	TestAssert.eq(world_ids.size(), 30, "30 unique world_id values")

	var data: Dictionary = TiItems.load_data()
	var coin_map: Dictionary = data.get("coin_map", {})
	var map_screens: Dictionary = {}
	for i in range(1, 31):
		var sid: String = str(coin_map.get(str(i), ""))
		TestAssert.false_(sid.is_empty(), "coin_map %d has screen" % i)
		map_screens[sid] = true
		TestAssert.true_(
			ResourceLoader.exists(levels_path.path_join("%s.tscn" % sid)),
			"coin_map screen exists: %s" % sid
		)


static func _count_coins(node: Node, screen_id: String, world_ids: Dictionary) -> int:
	var count := 0
	if "item_id" in node and str(node.get("item_id")) == "coin":
		count = 1
		var wid := ""
		if "world_id" in node:
			wid = str(node.get("world_id"))
		if wid.is_empty():
			wid = "%s/%s" % [screen_id, node.name]
		TestAssert.false_(world_ids.has(wid), "duplicate coin world_id: %s" % wid)
		world_ids[wid] = true
	for child in node.get_children():
		count += _count_coins(child, screen_id, world_ids)
	return count
