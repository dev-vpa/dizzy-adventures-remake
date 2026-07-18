class_name TestScreenManager
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")


static func run() -> void:
	ScreenManager.reset()
	ScreenManager.configure(TI_CONFIG)
	TestAssert.eq(ScreenManager.get_start_screen_id(), "beach_start", "start id from config")
	var container := Node2D.new()
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	ScreenManager.load_screen("beach_start", container, player)
	TestAssert.eq(ScreenManager.current_screen_id, "beach_start", "loaded beach_start")
	TestAssert.eq(container.get_child_count(), 1, "screen instance in container")
	ScreenManager.transition_to(
		"beach_wreck",
		Vector2(480, 350),
		container,
		player,
		"right"
	)
	TestAssert.eq(ScreenManager.current_screen_id, "beach_wreck", "transition to beach_wreck")
	container.queue_free()
	player.queue_free()
	ScreenManager.reset()
