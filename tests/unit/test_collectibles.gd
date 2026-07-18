class_name TestCollectibles
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

static func run() -> void:
	Collectibles.configure("coins", 30)
	Collectibles.reset()
	TestAssert.eq(Collectibles.total, 30, "total coins configured")
	TestAssert.eq(Collectibles.collected, 0, "starts at zero")
	TestAssert.true_(Collectibles.try_collect("coin"), "first coin collected")
	TestAssert.eq(Collectibles.collected, 1, "count increments")
	for i in range(28):
		Collectibles.try_collect("coin")
	TestAssert.eq(Collectibles.collected, 29, "29 coins collected")
	TestAssert.true_(Collectibles.try_collect("coin"), "30th coin collected")
	TestAssert.eq(Collectibles.collected, 30, "cap at 30")
	TestAssert.false_(Collectibles.try_collect("coin"), "31st coin rejected")
	TestAssert.true_(Collectibles.get_label().contains("30"), "label shows total")
