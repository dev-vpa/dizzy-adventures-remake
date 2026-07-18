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
