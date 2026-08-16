class_name GameScreen
extends Node2D

## Base flick-screen. Override exits in the editor or via @export.

const TOUCH_HINT_MARGIN := 8.0
const TOUCH_CONTROL_RECTS := [
	Rect2(736.0, 552.0, 272.0, 96.0), # Pick / Jump
	Rect2(768.0, 656.0, 240.0, 96.0), # Left / Right
]

@export var exit_left: String = ""
@export var exit_right: String = ""
@export var exit_up: String = ""
@export var exit_down: String = ""

@export_group("Spawn Overrides")
@export var override_spawn_from_west: bool = false
@export var spawn_from_west: Vector2 = Vector2(640, 640)
@export var override_spawn_from_east: bool = false
@export var spawn_from_east: Vector2 = Vector2(720, 640)
@export var override_spawn_from_north: bool = false
@export var spawn_from_north: Vector2 = Vector2(512, 640)
@export var override_spawn_from_south: bool = false
@export var spawn_from_south: Vector2 = Vector2(512, 640)

@export_group("Exit Zones")
@export var use_exit_up_zone: bool = false
@export var exit_up_zone: Rect2 = Rect2(352, 0, 320, 192)
@export var use_exit_down_zone: bool = false
@export var exit_down_zone: Rect2 = Rect2(16, 656, 352, 112)


func _ready() -> void:
	# Ledges must be one-way even if ArtSkin is missing (prevents floor wedge).
	_enable_ledge_one_way(self)
	# TI pixel skins (platforms / hazards / NPCs).
	var skin_path := "res://games/treasure-island/art_skin.gd"
	if ResourceLoader.exists(skin_path):
		(load(skin_path) as GDScript).call("apply_screen", self)
	if PlatformUI.is_touch_device():
		_apply_touch_hint_safe_areas()


func _enable_ledge_one_way(node: Node) -> void:
	if node is StaticBody2D:
		var n := String(node.name)
		if n != "Ground" and n != "Floor" and n != "Pier":
			if (
				n in ["Platform", "Ledge", "Balcony", "Bridge", "Roof", "Hut", "ShopFacade", "TreeStump", "Boulder", "RockBlock", "BarrelStack", "Counter"]
				or n.contains("Platform")
			):
				for child in node.get_children():
					if child is CollisionShape2D:
						(child as CollisionShape2D).one_way_collision = true
						(child as CollisionShape2D).one_way_collision_margin = 2.0
	for child in node.get_children():
		_enable_ledge_one_way(child)


func _apply_touch_hint_safe_areas() -> void:
	for node in find_children("*", "Label", true, false):
		var label := node as Label
		if label == null or not _is_world_hint(label):
			continue
		label.global_position += get_touch_hint_adjustment(label.get_global_rect())


func _is_world_hint(label: Label) -> bool:
	var node_name := String(label.name).to_lower()
	return (
		node_name.contains("hint")
		or node_name.contains("warn")
		or node_name.contains("status")
	)


func get_touch_hint_adjustment(hint_rect: Rect2) -> Vector2:
	var adjusted := hint_rect
	for _pass in TOUCH_CONTROL_RECTS.size():
		var moved := false
		for obstacle: Rect2 in TOUCH_CONTROL_RECTS:
			if not adjusted.intersects(obstacle):
				continue
			adjusted.position.y += obstacle.position.y - TOUCH_HINT_MARGIN - adjusted.end.y
			moved = true
		if not moved:
			break
	return adjusted.position - hint_rect.position


func get_exits() -> Dictionary:
	var exits := {}
	if not exit_left.is_empty():
		exits["left"] = exit_left
	if not exit_right.is_empty():
		exits["right"] = exit_right
	if not exit_up.is_empty():
		exits["up"] = exit_up
	if not exit_down.is_empty():
		exits["down"] = exit_down
	return exits


## Returns Vector2(-1, -1) when the default edge spawn should be used.
func get_spawn_for_entry(entry_direction: String, fallback_y: float) -> Vector2:
	var use_override := false
	var spawn := Vector2.ZERO
	match entry_direction:
		"right":
			use_override = override_spawn_from_west
			spawn = spawn_from_west
		"left":
			use_override = override_spawn_from_east
			spawn = spawn_from_east
		"down":
			use_override = override_spawn_from_north
			spawn = spawn_from_north
		"up":
			use_override = override_spawn_from_south
			spawn = spawn_from_south
		_:
			return Vector2(-1.0, -1.0)

	if not use_override:
		return Vector2(-1.0, -1.0)

	if spawn.y < 0.0:
		spawn.y = fallback_y
	return spawn


func point_in_up_exit_zone(point: Vector2) -> bool:
	if use_exit_up_zone:
		return exit_up_zone.has_point(point)
	return point.y <= 240.0


func point_in_down_exit_zone(point: Vector2) -> bool:
	if use_exit_down_zone:
		return exit_down_zone.has_point(point)
	return point.y >= 672.0
