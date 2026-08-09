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

	ScreenManager.current_screen_id = "cavern_kitchen_door"
	Inventory.clear()
	hooks._on_item_used("golden_key")
	TestAssert.false_(WorldState.get_flag("kitchen_open"), "kitchen needs key in inventory")
	Inventory.try_pick_up("golden_key")
	hooks._on_item_used("golden_key")
	TestAssert.true_(WorldState.get_flag("kitchen_open"), "key opens kitchen hatch")
	TestAssert.false_(Inventory.has_item("golden_key"), "golden key consumed")

	ScreenManager.current_screen_id = "pier_boat"
	Inventory.clear()
	Inventory.try_pick_up("outboard_motor")
	hooks._on_item_used("outboard_motor")
	TestAssert.false_(WorldState.get_flag("boat_outboard_motor"), "motor needs boat first")
	Inventory.clear()
	Inventory.try_pick_up("dehydrated_boat")
	hooks._on_item_used("dehydrated_boat")
	TestAssert.true_(WorldState.get_flag("boat_dehydrated_boat"), "boat hull fitted")
	Inventory.try_pick_up("outboard_motor")
	hooks._on_item_used("outboard_motor")
	Inventory.try_pick_up("petrol")
	hooks._on_item_used("petrol")
	Inventory.try_pick_up("ignition_key")
	hooks._on_item_used("ignition_key")
	TestAssert.true_(WorldState.get_flag("boat_ready"), "full boat ready")

	ScreenManager.current_screen_id = "shop_interior"
	Inventory.clear()
	Inventory.try_pick_up("video_camera")
	hooks._on_item_used("video_camera")
	TestAssert.true_(Inventory.has_item("dehydrated_boat"), "camera trades for boat")
	TestAssert.false_(Inventory.has_item("video_camera"), "traded item removed")

	Inventory.clear()
	Inventory.try_pick_up("microwave")
	hooks._on_item_used("microwave")
	TestAssert.true_(Inventory.has_item("petrol"), "microwave trades for petrol")
	TestAssert.false_(Inventory.has_item("microwave"), "microwave removed after trade")
	TestAssert.true_(WorldState.get_flag("traded_microwave"), "microwave trade flagged")

	Inventory.clear()
	Inventory.try_pick_up("cursed_treasure")
	hooks._on_item_used("cursed_treasure")
	TestAssert.true_(Inventory.has_item("outboard_motor"), "treasure trades for motor")
	Inventory.clear()
	Inventory.try_pick_up("gold_bag")
	hooks._on_item_used("gold_bag")
	TestAssert.true_(Inventory.has_item("ignition_key"), "gold bag trades for key")

	hooks.free()
	WorldState.reset()
	Inventory.clear()
	ScreenManager.reset()
