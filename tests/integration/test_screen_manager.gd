class_name TestScreenManager
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")


static func run() -> void:
	ScreenManager.reset()
	ScreenManager.configure(TI_CONFIG)
	var start_id: String = ScreenManager.get_start_screen_id()
	TestAssert.true_(not start_id.is_empty(), "start id from config")
	var container := Node2D.new()
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	ScreenManager.load_screen(start_id, container, player)
	TestAssert.eq(ScreenManager.current_screen_id, start_id, "loaded start screen")
	TestAssert.eq(container.get_child_count(), 1, "screen instance in container")
	ScreenManager.transition_to(
		"beach_wreck",
		Vector2(480, 350),
		container,
		player,
		"right"
	)
	TestAssert.eq(ScreenManager.current_screen_id, "beach_wreck", "transition to beach_wreck")
	WorldState.reset()
	TestAssert.false_(
		ScreenManager._can_use_edge_exit("mine_gold_room"),
		"gold room blocked before blast"
	)
	WorldState.set_flag("mine_blasted")
	TestAssert.true_(
		ScreenManager._can_use_edge_exit("mine_gold_room"),
		"gold room open after blast"
	)
	TestAssert.false_(
		ScreenManager._can_use_directional_exit("down", "bridge_cavern_west"),
		"bridge cavern blocked before cut"
	)
	WorldState.set_flag("bridge_cut")
	TestAssert.true_(
		ScreenManager._can_use_directional_exit("down", "bridge_cavern_west"),
		"bridge cavern open after cut"
	)
	TestAssert.false_(
		ScreenManager._can_use_directional_exit("down", "blackbeard_kitchen"),
		"kitchen blocked before key"
	)
	WorldState.set_flag("kitchen_open")
	TestAssert.true_(
		ScreenManager._can_use_directional_exit("down", "blackbeard_kitchen"),
		"kitchen open after key"
	)
	container.queue_free()
	player.queue_free()
	WorldState.reset()
	ScreenManager.reset()
