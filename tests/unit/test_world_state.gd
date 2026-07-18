class_name TestWorldState
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

static func run() -> void:
	WorldState.reset()
	TestAssert.false_(WorldState.is_collected("beach_start/coin_1"), "fresh run not collected")
	WorldState.mark_collected("beach_start/coin_1")
	TestAssert.true_(WorldState.is_collected("beach_start/coin_1"), "marked collected")
	WorldState.mark_collected("")
	TestAssert.false_(WorldState.is_collected(""), "empty id not collected")
	TestAssert.false_(WorldState.get_flag("ocean_bubbles"), "flag starts false")
	WorldState.set_flag("ocean_bubbles")
	TestAssert.true_(WorldState.get_flag("ocean_bubbles"), "flag set")
	WorldState.reset()
	TestAssert.false_(WorldState.is_collected("beach_start/coin_1"), "reset clears state")
	TestAssert.false_(WorldState.get_flag("ocean_bubbles"), "reset clears flags")
