class_name GameScreen
extends Node2D

## Base flick-screen. Override exits in the editor or via @export.

@export var exit_left: String = ""
@export var exit_right: String = ""
@export var exit_up: String = ""
@export var exit_down: String = ""

@export_group("Spawn Overrides")
@export var override_spawn_from_west: bool = false
@export var spawn_from_west: Vector2 = Vector2(320, 320)
@export var override_spawn_from_east: bool = false
@export var spawn_from_east: Vector2 = Vector2(360, 320)
@export var override_spawn_from_north: bool = false
@export var spawn_from_north: Vector2 = Vector2(256, 320)
@export var override_spawn_from_south: bool = false
@export var spawn_from_south: Vector2 = Vector2(256, 320)

@export_group("Exit Zones")
@export var use_exit_up_zone: bool = false
@export var exit_up_zone: Rect2 = Rect2(176, 0, 160, 96)
@export var use_exit_down_zone: bool = false
@export var exit_down_zone: Rect2 = Rect2(8, 328, 176, 56)


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
	return point.y <= 120.0


func point_in_down_exit_zone(point: Vector2) -> bool:
	if use_exit_down_zone:
		return exit_down_zone.has_point(point)
	return point.y >= 336.0
