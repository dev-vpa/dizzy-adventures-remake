class_name TestInventory
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

static func run() -> void:
	Inventory.configure(3)
	Inventory.clear()
	TestAssert.eq(Inventory.max_slots, 3, "inventory slots configured")
	TestAssert.false_(Inventory.is_full(), "starts not full")
	TestAssert.true_(Inventory.try_pick_up("snorkel"), "pick up snorkel")
	TestAssert.true_(Inventory.has_item("snorkel"), "has snorkel")
	TestAssert.false_(Inventory.try_pick_up("snorkel"), "duplicate rejected")
	TestAssert.true_(Inventory.try_pick_up("glass_sword"), "pick up sword")
	TestAssert.true_(Inventory.try_pick_up("salt_spade"), "pick up spade")
	TestAssert.true_(Inventory.is_full(), "three items fills slots")
	TestAssert.false_(Inventory.try_pick_up("coin"), "full inventory rejects")
	TestAssert.eq(Inventory.get_selected_item(), "snorkel", "first item selected")
	Inventory.select_next()
	TestAssert.eq(Inventory.get_selected_item(), "glass_sword", "cycle selection")
	TestAssert.true_(Inventory.try_use_selected(), "use emits for selected")
	var dropped := Inventory.try_drop_selected()
	TestAssert.eq(dropped, "glass_sword", "drop selected item")
	TestAssert.eq(Inventory.get_items().size(), 2, "two items after drop")
