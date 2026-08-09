class_name TestArtSkin
extends RefCounted

const TestAssert := preload("res://tests/test_assert.gd")
const LevelRegistryHelper := preload("res://tests/helpers/level_registry_helper.gd")
const ArtSkin := preload("res://games/treasure-island/art_skin.gd")

const LEVELS := "res://games/treasure-island/levels"


static func run() -> void:
	_assert_all_level_rects_are_resolved()
	_assert_shop_facade()
	_assert_dynamic_props()
	_assert_special_surfaces()


static func _assert_all_level_rects_are_resolved() -> void:
	for screen_id in LevelRegistryHelper.list_screen_ids(LEVELS):
		var packed: PackedScene = load(LEVELS.path_join("%s.tscn" % screen_id))
		var screen := packed.instantiate()
		ArtSkin.apply_screen(screen)
		_assert_no_solid_rects(screen, screen_id)
		screen.free()


static func _assert_no_solid_rects(node: Node, screen_id: String) -> void:
	if node is ColorRect:
		var rect := node as ColorRect
		TestAssert.true_(
			not rect.visible or rect.color.a <= 0.001,
			"%s resolves ColorRect %s/%s"
			% [screen_id, String(rect.get_parent().name), String(rect.name)]
		)
	for child in node.get_children():
		_assert_no_solid_rects(child, screen_id)


static func _assert_shop_facade() -> void:
	var screen := _skinned_screen("shop_exterior")
	_assert_texture(screen, "ShopFacade/Visual", "shop_facade.png")
	var old_door := screen.get_node("ShopFacade/DoorVisual") as ColorRect
	TestAssert.false_(old_door.visible, "shop facade hides legacy door block")
	screen.free()


static func _assert_dynamic_props() -> void:
	var boat_screen := _skinned_screen("pier_boat")
	_assert_texture(boat_screen, "Motor", "motor.png")
	var motor := boat_screen.get_node("Motor") as ColorRect
	TestAssert.false_(motor.visible, "motor keeps initial flag-driven visibility")
	boat_screen.free()

	var bubble_screen := _skinned_screen("ocean_bubble_cave")
	_assert_texture(bubble_screen, "BubbleA", "bubble.png")
	_assert_texture(bubble_screen, "AscendPad", "zone_glow_blue.png")
	var bubble := bubble_screen.get_node("BubbleA") as ColorRect
	TestAssert.false_(bubble.visible, "bubble keeps initial flag-driven visibility")
	var water := bubble_screen.get_node("FullWater/Visual") as ColorRect
	TestAssert.false_(water.visible, "ocean backdrop replaces full-screen water block")
	bubble_screen.free()

	var fish_screen := _skinned_screen("ocean_fish_run")
	_assert_texture(fish_screen, "Hazard1/Visual", "fish.png")
	TestAssert.eq(
		fish_screen.get_node_or_null("Hazard1/HazardSprite"),
		null,
		"patrol hazard art stays attached to its moving Visual"
	)
	fish_screen.free()


static func _assert_special_surfaces() -> void:
	var barrel_screen := _skinned_screen("cavern_barrels")
	_assert_texture(barrel_screen, "BarrelStack/Visual", "barrel_stack.png")
	_assert_texture(barrel_screen, "BarrelA", "barrel.png")
	var wall := barrel_screen.get_node("Wall") as ColorRect
	TestAssert.false_(wall.visible, "authored cavern backdrop replaces wall tint")
	barrel_screen.free()

	var pier_screen := _skinned_screen("beach_jetty")
	_assert_texture(pier_screen, "Pier/Visual", "pier.png")
	_assert_texture(pier_screen, "ShallowWater/Visual", "water.png")
	pier_screen.free()

	var cave_screen := _skinned_screen("cave_entrance")
	_assert_texture(cave_screen, "Boulder/Visual", "boulder.png")
	TestAssert.false_((cave_screen.get_node("Cave") as ColorRect).visible, "cave block is hidden")
	TestAssert.false_((cave_screen.get_node("Sky") as ColorRect).visible, "sky block is hidden")
	cave_screen.free()


static func _skinned_screen(screen_id: String) -> Node:
	var packed: PackedScene = load(LEVELS.path_join("%s.tscn" % screen_id))
	var screen := packed.instantiate()
	ArtSkin.apply_screen(screen)
	return screen


static func _assert_texture(root: Node, node_path: String, expected_file: String) -> void:
	var rect := root.get_node_or_null(node_path) as ColorRect
	TestAssert.ne(rect, null, "%s exists" % node_path)
	if rect == null:
		return
	var art := rect.get_node_or_null("ArtTexture") as TextureRect
	TestAssert.ne(art, null, "%s has generated art" % node_path)
	if art == null or art.texture == null:
		return
	TestAssert.true_(
		art.texture.resource_path.ends_with(expected_file),
		"%s uses %s" % [node_path, expected_file]
	)
