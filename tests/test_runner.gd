extends Node

## Headless test entry point. Run: godot --headless --path . res://tests/test_runner.tscn

const _TestAssert := preload("res://tests/test_assert.gd")
const _TestWorldState := preload("res://tests/unit/test_world_state.gd")
const _TestInventory := preload("res://tests/unit/test_inventory.gd")
const _TestCollectibles := preload("res://tests/unit/test_collectibles.gd")
const _TestItemCatalog := preload("res://tests/unit/test_item_catalog.gd")
const _TestTiItems := preload("res://tests/unit/test_ti_items.gd")
const _TestTiGameplay := preload("res://tests/unit/test_ti_gameplay.gd")
const _TestGameScreen := preload("res://tests/unit/test_game_screen.gd")
const _TestLevelPlayability := preload("res://tests/unit/test_level_playability.gd")
const _TestCoinLayout := preload("res://tests/unit/test_coin_layout.gd")
const _TestScreenRegistry := preload("res://tests/integration/test_screen_registry.gd")
const _TestScreenManager := preload("res://tests/integration/test_screen_manager.gd")
const _TestWinPath := preload("res://tests/integration/test_win_path.gd")

var _suites: Array[Dictionary] = []


func _init() -> void:
	_suites = [
		{"name": "WorldState", "script": _TestWorldState},
		{"name": "Inventory", "script": _TestInventory},
		{"name": "Collectibles", "script": _TestCollectibles},
		{"name": "ItemCatalog", "script": _TestItemCatalog},
		{"name": "TiItems", "script": _TestTiItems},
		{"name": "TiGameplay", "script": _TestTiGameplay},
		{"name": "GameScreen", "script": _TestGameScreen},
		{"name": "LevelPlayability", "script": _TestLevelPlayability},
		{"name": "CoinLayout", "script": _TestCoinLayout},
		{"name": "ScreenRegistry", "script": _TestScreenRegistry},
		{"name": "ScreenManager", "script": _TestScreenManager},
		{"name": "WinPath", "script": _TestWinPath},
	]


func _ready() -> void:
	_TestAssert.reset()
	print("=== Dizzy Adventures Remake — tests ===")
	for suite in _suites:
		var before: int = _TestAssert.failure_count
		print("  • %s" % suite.name)
		if suite.script != null and suite.script.has_method("run"):
			suite.script.run()
		else:
			_TestAssert.ok(false, "%s: missing run()" % suite.name)
		var added: int = _TestAssert.failure_count - before
		if added == 0:
			print("    OK")
		else:
			print("    %d failure(s)" % added)
	_finish()


func _finish() -> void:
	print("---")
	print(
		"Passed checks: %d | Failures: %d"
		% [_TestAssert.pass_count, _TestAssert.failure_count]
	)
	var exit_code := 1 if _TestAssert.failure_count > 0 else 0
	if exit_code == 0:
		print("ALL TESTS PASSED")
	else:
		push_error("TESTS FAILED (%d)" % _TestAssert.failure_count)
	get_tree().quit(exit_code)
