class_name TestSaveGame
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")

static func run() -> void:
	var game_id := "treasure-island-test"
	SaveGame.delete_save(game_id)
	TestAssert.false_(SaveGame.has_save(game_id), "no save initially")

	WorldState.reset()
	WorldState.set_flag("bridge_cut")
	WorldState.mark_collected("beach_start/coin1")
	Inventory.configure(3)
	Inventory.try_pick_up("snorkel")
	Inventory.try_pick_up("salt_spade")
	Collectibles.configure("coin", 30)
	Collectibles.set_collected(4)
	Lives.configure(1)

	# Simulate playing so request_save is allowed.
	GameManager.active_config = GameManager.get_available_games()[0]
	GameManager.state = GameManager.State.PLAYING
	ScreenManager.current_screen_id = "beach_start"
	SaveGame.clear_runtime()
	var uid := SaveGame.record_drop("beach_start", "toothpaste", Vector2(100, 340))
	TestAssert.true_(not uid.is_empty(), "drop uid")

	SaveGame.request_save(game_id)
	TestAssert.true_(SaveGame.has_save(game_id), "save written")

	WorldState.reset()
	Inventory.clear()
	Collectibles.reset()
	SaveGame.clear_runtime()

	TestAssert.true_(SaveGame.begin_continue(game_id), "load save")
	TestAssert.true_(WorldState.get_flag("bridge_cut"), "flag restored")
	TestAssert.true_(WorldState.is_collected("beach_start/coin1"), "collected restored")
	TestAssert.true_(Inventory.has_item("snorkel"), "inventory restored")
	TestAssert.eq(Collectibles.collected, 4, "coins restored")
	var restore := SaveGame.consume_restore()
	TestAssert.eq(str(restore.get("screen_id", "")), "beach_start", "screen restored")

	SaveGame.delete_save(game_id)
	GameManager.state = GameManager.State.MAIN_MENU
	GameManager.active_config = null
	WorldState.reset()
	Inventory.clear()
	Collectibles.reset()
	SaveGame.clear_runtime()
