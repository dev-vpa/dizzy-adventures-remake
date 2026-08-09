class_name TestTiItems
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")
const TiItems := preload("res://games/treasure-island/ti_items.gd")

static func run() -> void:
	var data: Dictionary = TiItems.load_data()
	TestAssert.false_(data.is_empty(), "items.json loads")
	var items: Array = data.get("items", [])
	TestAssert.true_(items.size() >= 30, "items list populated")
	var ids: Dictionary = {}
	for entry: Dictionary in items:
		var id: String = entry.get("id", "")
		TestAssert.false_(id.is_empty(), "item has id")
		TestAssert.false_(ids.has(id), "duplicate item id: %s" % id)
		ids[id] = true
	var coin_map: Dictionary = data.get("coin_map", {})
	for i in range(1, 31):
		TestAssert.true_(coin_map.has(str(i)), "coin_map has entry %d" % i)
	var trade: Array = data.get("trade_order", [])
	TestAssert.eq(trade.size(), 4, "four shop trades")
	var boat: Array = data.get("boat_parts", [])
	TestAssert.eq(boat.size(), 4, "four boat parts")
	TestAssert.eq(TiItems.get_display_name("snorkel"), "Rubber Snorkel", "ti display name")
	var levels_path := "res://games/treasure-island/levels"
	for entry: Dictionary in items:
		if not bool(entry.get("essential", false)):
			continue
		if not str(entry.get("obtained_from", "")).is_empty():
			continue
		var screen: String = str(entry.get("screen", ""))
		var item_id: String = str(entry.get("id", ""))
		if screen.is_empty() or item_id.is_empty():
			continue
		var scene_path := levels_path.path_join("%s.tscn" % screen)
		TestAssert.true_(ResourceLoader.exists(scene_path), "essential %s screen exists: %s" % [item_id, screen])
		var packed: PackedScene = load(scene_path)
		TestAssert.ne(packed, null, "essential %s scene loads" % item_id)
		var root: Node = packed.instantiate()
		TestAssert.true_(
			_tree_has_item(root, item_id),
			"essential %s placed on %s" % [item_id, screen]
		)
		root.free()


static func _tree_has_item(node: Node, item_id: String) -> bool:
	if "item_id" in node and str(node.get("item_id")) == item_id:
		return true
	for child in node.get_children():
		if _tree_has_item(child, item_id):
			return true
	return false
