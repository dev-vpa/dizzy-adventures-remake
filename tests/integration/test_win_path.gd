class_name TestWinPath
extends RefCounted

## Virtual start→win path: map connectivity + puzzle/trade/boat sequence from beach_start.

const TestAssert := preload("res://tests/test_assert.gd")
const LevelRegistryHelper := preload("res://tests/helpers/level_registry_helper.gd")
const TiGameplay := preload("res://games/treasure-island/ti_gameplay.gd")

const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")

## Screens a full playthrough must be able to reach via exits/doors (graph, not physics).
const PATH_CHECKPOINTS := [
	"beach_start",
	"beach_wreck",
	"cliff_ascent",
	"bridge_approach",
	"tree_village_gate",
	"tree_upper_central",
	"tree_upper_east",
	"tree_camera_ledge",
	"tree_rail_coin",
	"tree_magazine",
	"tree_snorkel_hut",
	"tree_above_mine",
	"mine_shaft",
	"mine_blast",
	"mine_gold_room",
	"ocean_entry",
	"ocean_fish_run",
	"ocean_wreck",
	"ocean_spade_bay",
	"ocean_bubble_cave",
	"ocean_bubble_ascend",
	"grave_hill",
	"cavern_grave_entry",
	"cavern_skull_room",
	"cavern_barrels",
	"cavern_kitchen_door",
	"blackbeard_kitchen",
	"bridge_cavern_west",
	"bridge_cavern_treasure",
	"totem_pole",
	"shop_exterior",
	"shop_interior",
	"pier_key",
	"pier_boat",
	"taxman_dock",
]


static func run() -> void:
	TestAssert.eq(
		TI_CONFIG.starting_screen_id,
		"beach_start",
		"full playthrough starts at beach_start"
	)
	var levels_path: String = TI_CONFIG.levels_path
	var reachable := LevelRegistryHelper.reachable_from("beach_start", levels_path)
	for screen_id in PATH_CHECKPOINTS:
		TestAssert.true_(
			screen_id in reachable,
			"beach_start graph reaches %s" % screen_id
		)

	_assert_gates_then_scripted_win()


static func _assert_gates_then_scripted_win() -> void:
	WorldState.reset()
	Inventory.configure(TI_CONFIG.inventory_slots)
	Inventory.clear()
	Collectibles.configure(TI_CONFIG.collectible_name, TI_CONFIG.collectible_total)
	Collectibles.reset()
	ScreenManager.reset()
	ScreenManager.configure(TI_CONFIG)

	TestAssert.false_(
		ScreenManager._can_use_directional_exit("up", "ocean_bubble_ascend"),
		"bubbles gate closed at start"
	)
	TestAssert.false_(
		ScreenManager._can_use_directional_exit("down", "cavern_grave_entry"),
		"grave gate closed at start"
	)
	TestAssert.false_(
		ScreenManager._can_use_directional_exit("down", "bridge_cavern_west"),
		"bridge gate closed at start"
	)
	TestAssert.false_(
		ScreenManager._can_use_directional_exit("down", "blackbeard_kitchen"),
		"kitchen gate closed at start"
	)
	TestAssert.false_(
		ScreenManager._can_use_edge_exit("mine_gold_room"),
		"mine gate closed at start"
	)

	var hooks: Node = TiGameplay.new()

	# Ocean → east shore (snorkel required for any ocean_* exit target)
	ScreenManager.current_screen_id = "ocean_bubble_cave"
	Inventory.try_pick_up("snorkel")
	Inventory.try_pick_up("salt_spade")
	hooks._on_item_used("salt_spade")
	TestAssert.true_(WorldState.get_flag("ocean_bubbles"), "path: dig bubbles")
	TestAssert.true_(
		ScreenManager._can_use_directional_exit("up", "ocean_bubble_ascend"),
		"path: ascend open after dig + snorkel"
	)

	# Grave → cavern → kitchen
	ScreenManager.current_screen_id = "grave_hill"
	Inventory.clear()
	Inventory.try_pick_up("glass_sword")
	hooks._on_item_used("glass_sword")
	TestAssert.true_(WorldState.get_flag("grave_open"), "path: open grave")
	TestAssert.true_(
		ScreenManager._can_use_directional_exit("down", "cavern_grave_entry"),
		"path: cavern entry open"
	)

	ScreenManager.current_screen_id = "cavern_kitchen_door"
	Inventory.clear()
	Inventory.try_pick_up("golden_key")
	hooks._on_item_used("golden_key")
	TestAssert.true_(WorldState.get_flag("kitchen_open"), "path: open kitchen")
	TestAssert.true_(
		ScreenManager._can_use_directional_exit("down", "blackbeard_kitchen"),
		"path: kitchen open"
	)

	# Bridge cavern + cursed treasure route
	ScreenManager.current_screen_id = "bridge_approach"
	hooks._on_item_used("woodcutters_axe")
	TestAssert.true_(WorldState.get_flag("bridge_cut"), "path: cut bridge")
	TestAssert.true_(
		ScreenManager._can_use_directional_exit("down", "bridge_cavern_west"),
		"path: bridge cavern open"
	)

	# Mine gold
	ScreenManager.current_screen_id = "mine_blast"
	Inventory.clear()
	Inventory.try_pick_up("dynamite")
	Inventory.try_pick_up("detonator")
	hooks._on_item_used("detonator")
	TestAssert.true_(WorldState.get_flag("mine_blasted"), "path: blast mine")
	TestAssert.true_(
		ScreenManager._can_use_edge_exit("mine_gold_room"),
		"path: gold room open"
	)

	# Shop trades → boat parts (camera → boat, treasure → motor, microwave → petrol, gold → key)
	ScreenManager.current_screen_id = "shop_interior"
	Inventory.clear()
	Inventory.try_pick_up("video_camera")
	hooks._on_item_used("video_camera")
	TestAssert.true_(Inventory.has_item("dehydrated_boat"), "path: trade boat")
	Inventory.clear()
	Inventory.try_pick_up("cursed_treasure")
	hooks._on_item_used("cursed_treasure")
	TestAssert.true_(Inventory.has_item("outboard_motor"), "path: trade motor")
	Inventory.clear()
	Inventory.try_pick_up("microwave")
	hooks._on_item_used("microwave")
	TestAssert.true_(Inventory.has_item("petrol"), "path: trade petrol")
	Inventory.clear()
	Inventory.try_pick_up("gold_bag")
	hooks._on_item_used("gold_bag")
	TestAssert.true_(Inventory.has_item("ignition_key"), "path: trade ignition key")

	# Assemble boat in order
	ScreenManager.current_screen_id = "pier_boat"
	Inventory.clear()
	for part_id in ["dehydrated_boat", "outboard_motor", "petrol", "ignition_key"]:
		Inventory.try_pick_up(part_id)
		hooks._on_item_used(part_id)
	TestAssert.true_(WorldState.get_flag("boat_ready"), "path: boat ready")

	Collectibles.set_collected(Collectibles.total)
	TestAssert.eq(Collectibles.collected, 30, "path: 30 coins for Taxman")
	TestAssert.true_(
		WorldState.get_flag("boat_ready") and Collectibles.collected >= Collectibles.total,
		"path: Taxman win conditions met"
	)

	hooks.free()
	WorldState.reset()
	Inventory.clear()
	Collectibles.reset()
	ScreenManager.reset()
