class_name TestScreenRegistry
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")
const LevelRegistryHelper := preload("res://tests/helpers/level_registry_helper.gd")

const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")


static func run() -> void:
	var levels_path: String = TI_CONFIG.levels_path
	var ids := LevelRegistryHelper.list_screen_ids(levels_path)
	TestAssert.true_(ids.size() >= 27, "at least 27 TI level scenes (got %d)" % ids.size())
	TestAssert.true_("beach_start" in ids, "beach_start exists")
	TestAssert.eq(TI_CONFIG.starting_screen_id, "beach_start", "config start screen")
	for screen_id in ids:
		var path := levels_path.path_join("%s.tscn" % screen_id)
		TestAssert.true_(ResourceLoader.exists(path), "scene exists: %s" % screen_id)
		var packed: PackedScene = load(path)
		TestAssert.ne(packed, null, "scene loads: %s" % screen_id)
		var instance: Node = packed.instantiate()
		TestAssert.true_(
			instance.has_method("get_exits"),
			"GameScreen API: %s" % screen_id
		)
		var exits: Dictionary = instance.call("get_exits")
		for direction in exits:
			var target: String = exits[direction]
			TestAssert.true_(
				target in ids,
				"%s exit_%s → unknown '%s'" % [screen_id, direction, target]
			)
		instance.free()
	var reachable := LevelRegistryHelper.reachable_from("beach_start", levels_path)
	TestAssert.true_(
		reachable.size() >= 20,
		"beach_start reaches most of map (got %d screens)" % reachable.size()
	)
	TestAssert.true_("tree_snorkel_hut" in reachable, "snorkel hut reachable from start")
	TestAssert.true_("shop_exterior" in reachable, "shop exterior reachable from start")
	TestAssert.true_("shop_interior" in ids, "shop interior scene exists")
