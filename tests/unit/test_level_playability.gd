class_name TestLevelPlayability
extends RefCounted

## Guards against unreachable climb platforms / unjumpable floor traps / broken ↑ exits.

const TestAssert := preload("res://tests/test_assert.gd")
const LevelRegistryHelper := preload("res://tests/helpers/level_registry_helper.gd")

const TI_CONFIG := preload("res://games/treasure-island/treasure_island_config.tres")

## Jump height ~104px from floor; climb platforms (h≈32) must sit at y >= this.
const MIN_CLIMB_PLATFORM_Y := 656.0
## Floor traps wider than this are hard/impossible to clear from standing edge.
const MAX_FLOOR_TRAP_WIDTH := 80.0
const FLOOR_TRAP_MIN_Y := 680.0
## Standing Dizzy on ground (feet ≈704): collision roughly y 652–708.
const STAND_BODY_TOP := 652.0
const STAND_BODY_BOTTOM := 708.0

const CLIMB_NAMES := {
	"Platform": true,
	"Pier": true,
	"Ledge": true,
	"Bridge": true,
	"Balcony": true,
	"Roof": true,
}


static func run() -> void:
	var levels_path: String = TI_CONFIG.levels_path
	for screen_id in LevelRegistryHelper.list_screen_ids(levels_path):
		var path := levels_path.path_join("%s.tscn" % screen_id)
		var packed: PackedScene = load(path)
		if packed == null:
			TestAssert.ok(false, "playability load: %s" % screen_id)
			continue
		var root: Node = packed.instantiate()
		_check_exit_up(screen_id, root)
		_check_climb_platforms(screen_id, root)
		_check_floor_traps(screen_id, root)
		_check_path_hazard_height(screen_id, root)
		root.free()


static func _is_aquatic_screen(screen_id: String, root: Node) -> bool:
	if screen_id.begins_with("ocean_") or screen_id.begins_with("underwater_"):
		return true
	for child in root.get_children():
		var n := String(child.name)
		if n.contains("Water") or n.contains("water"):
			return true
	return false


static func _check_exit_up(screen_id: String, root: Node) -> void:
	if not ("exit_up" in root):
		return
	var exit_up: String = root.get("exit_up")
	if exit_up.is_empty():
		return
	TestAssert.true_(
		bool(root.get("use_exit_up_zone")),
		"%s: exit_up set but use_exit_up_zone is false (default needs y<=240)" % screen_id
	)
	# Underwater screens use a top-of-screen ↑ zone; land screens need a floor zone.
	if _is_aquatic_screen(screen_id, root):
		return
	var zone: Rect2 = root.get("exit_up_zone")
	TestAssert.true_(
		zone.position.y >= 400.0,
		"%s: exit_up_zone too high (y=%.0f) — unreachable from floor" % [screen_id, zone.position.y]
	)


static func _check_climb_platforms(screen_id: String, root: Node) -> void:
	for node in root.get_children():
		if not (node is StaticBody2D):
			continue
		# Optional decorative high ledge with trap on top (not required to climb).
		if screen_id == "tree_upper_far_west" and node.name == "Ledge":
			continue
		if not CLIMB_NAMES.has(String(node.name)):
			continue
		TestAssert.true_(
			node.position.y >= MIN_CLIMB_PLATFORM_Y,
			"%s/%s climb platform y=%.0f < %.0f (jump too short)"
			% [screen_id, node.name, node.position.y, MIN_CLIMB_PLATFORM_Y]
		)


static func _check_floor_traps(screen_id: String, root: Node) -> void:
	for node in root.get_children():
		var n := String(node.name)
		if not (n.contains("Trap") or n.contains("Hazard")):
			continue
		if not ("zone_size" in node) or not ("zone_center" in node):
			continue
		var size: Vector2 = node.get("zone_size")
		var center: Vector2 = node.get("zone_center")
		if center.y < FLOOR_TRAP_MIN_Y:
			continue
		TestAssert.true_(
			size.x <= MAX_FLOOR_TRAP_WIDTH,
			"%s/%s floor trap width=%.0f > %.0f (unjumpable)"
			% [screen_id, node.name, size.x, MAX_FLOOR_TRAP_WIDTH]
		)


static func _check_path_hazard_height(screen_id: String, root: Node) -> void:
	## Path hazards must overlap standing Dizzy — not float above so you walk under them.
	## Ledge* traps are allowed high (punish climbing a high platform).
	for node in root.get_children():
		var n := String(node.name)
		if not (n.contains("Trap") or n.contains("Hazard")):
			continue
		if n.contains("Ledge"):
			continue
		if not ("zone_size" in node) or not ("zone_center" in node):
			continue
		var size: Vector2 = node.get("zone_size")
		var center: Vector2 = node.get("zone_center")
		var top := center.y - size.y * 0.5
		var bottom := center.y + size.y * 0.5
		var overlaps_stand := bottom > STAND_BODY_TOP and top < STAND_BODY_BOTTOM
		TestAssert.true_(
			overlaps_stand,
			"%s/%s hazard y=%.0f–%.0f misses standing body %.0f–%.0f (walk-under bug)"
			% [screen_id, n, top, bottom, STAND_BODY_TOP, STAND_BODY_BOTTOM]
		)
