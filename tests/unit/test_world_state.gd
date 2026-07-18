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
	WorldState.reset()
	TestAssert.false_(WorldState.is_collected("beach_start/coin_1"), "reset clears state")
