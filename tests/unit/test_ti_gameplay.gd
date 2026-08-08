class_name TestTiGameplay
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")
const TiGameplay := preload("res://games/treasure-island/ti_gameplay.gd")


static func run() -> void:
	WorldState.reset()
	Inventory.configure(3)
	Inventory.clear()
	ScreenManager.reset()
	ScreenManager.current_screen_id = "ocean_bubble_cave"
	var hooks: Node = TiGameplay.new()
	hooks._on_item_used("salt_spade")
	TestAssert.true_(WorldState.get_flag("ocean_bubbles"), "spade sets ocean_bubbles")
	ScreenManager.current_screen_id = "grave_hill"
	hooks._on_item_used("glass_sword")
	TestAssert.true_(WorldState.get_flag("grave_open"), "sword opens grave")
	ScreenManager.current_screen_id = "bridge_approach"
	hooks._on_item_used("woodcutters_axe")
	TestAssert.true_(WorldState.get_flag("bridge_cut"), "axe cuts bridge")

	ScreenManager.current_screen_id = "mine_blast"
	Inventory.clear()
	Inventory.try_pick_up("dynamite")
	hooks._on_item_used("dynamite")
	TestAssert.false_(WorldState.get_flag("mine_blasted"), "mine needs both items")
	Inventory.try_pick_up("detonator")
	hooks._on_item_used("detonator")
	TestAssert.true_(WorldState.get_flag("mine_blasted"), "mine blasted with both")
	TestAssert.false_(Inventory.has_item("dynamite"), "dynamite consumed")
	TestAssert.false_(Inventory.has_item("detonator"), "detonator consumed")

	ScreenManager.current_screen_id = "shop_interior"
	Inventory.clear()
	Inventory.try_pick_up("video_camera")
	hooks._on_item_used("video_camera")
	TestAssert.true_(Inventory.has_item("dehydrated_boat"), "camera trades for boat")
	TestAssert.false_(Inventory.has_item("video_camera"), "traded item removed")
	hooks.free()
	WorldState.reset()
	Inventory.clear()
	ScreenManager.reset()
