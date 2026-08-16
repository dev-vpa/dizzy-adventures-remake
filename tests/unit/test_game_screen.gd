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
	TestAssert.true_(screen.call("point_in_down_exit_zone", Vector2(180, 700)), "jetty down zone")
	TestAssert.false_(screen.call("point_in_down_exit_zone", Vector2(800, 700)), "outside down zone")
	var spawn: Vector2 = screen.call("get_spawn_for_entry", "up", 320.0)
	TestAssert.true_(spawn.x >= 0.0, "spawn override from south (underwater entry)")
	TestAssert.eq(spawn.x, 180.0, "south spawn x")
	_assert_touch_hint_safe_areas(screen)
	screen.free()
	_assert_hud_clearance("ocean_entry", "UpHint")
	_assert_hud_clearance("taxman_dock", "EndHint")
	_assert_hud_clearance("blackbeard_kitchen", "Title")


static func _assert_touch_hint_safe_areas(screen: Node) -> void:
	var right_hint := Rect2(840.0, 704.0, 168.0, 32.0)
	var right_adjustment: Vector2 = screen.call("get_touch_hint_adjustment", right_hint)
	TestAssert.true_(right_adjustment.y < 0.0, "right hint moves above touch controls")
	TestAssert.eq(
		right_hint.end.y + right_adjustment.y,
		544.0,
		"right hint clears both touch-control rows"
	)

	var pickup_hint := Rect2(768.0, 606.0, 64.0, 28.0)
	var pickup_adjustment: Vector2 = screen.call("get_touch_hint_adjustment", pickup_hint)
	TestAssert.eq(
		pickup_hint.end.y + pickup_adjustment.y,
		544.0,
		"pickup hint keeps an 8 px action-control margin"
	)

	var left_hint := Rect2(16.0, 704.0, 224.0, 32.0)
	TestAssert.eq(
		screen.call("get_touch_hint_adjustment", left_hint),
		Vector2.ZERO,
		"left hint stays at the screen edge"
	)


static func _assert_hud_clearance(level_id: String, node_path: String) -> void:
	var packed := load("%s/%s.tscn" % [LEVELS, level_id]) as PackedScene
	TestAssert.ne(packed, null, "%s loads for hint layout" % level_id)
	if packed == null:
		return
	var level := packed.instantiate()
	var hint := level.get_node_or_null(node_path) as Label
	TestAssert.ne(hint, null, "%s/%s exists" % [level_id, node_path])
	if hint != null:
		TestAssert.true_(
			hint.offset_top >= 232.0,
			"%s/%s clears the touch HUD" % [level_id, node_path]
		)
	level.free()
