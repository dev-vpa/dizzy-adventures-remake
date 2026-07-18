class_name TestGameScreen
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

const LEVELS := "res://games/treasure-island/levels"


static func run() -> void:
	var packed: PackedScene = load("%s/beach_jetty.tscn" % LEVELS)
	var screen: Node = packed.instantiate()
	TestAssert.true_(screen.has_method("get_exits"), "beach_jetty has get_exits")
	var exits: Dictionary = screen.call("get_exits")
	TestAssert.true_(exits.has("left"), "jetty exit left")
	TestAssert.eq(exits["left"], "beach_right", "jetty left target")
	TestAssert.true_(screen.call("point_in_down_exit_zone", Vector2(90, 350)), "jetty down zone")
	TestAssert.false_(screen.call("point_in_down_exit_zone", Vector2(400, 350)), "outside down zone")
	var spawn: Vector2 = screen.call("get_spawn_for_entry", "up", 320.0)
	TestAssert.true_(spawn.x >= 0.0, "spawn override from south (underwater entry)")
	TestAssert.eq(spawn.x, 90.0, "south spawn x")
	screen.free()
