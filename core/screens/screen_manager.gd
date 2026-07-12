extends Node

## Flick-screen navigation: one active screen at a time, edge transitions.

signal screen_changed(screen_id: String)

const SCREEN_WIDTH := 512
const SCREEN_HEIGHT := 384
const EDGE_MARGIN := 8.0
const SPAWN_INSET := 24.0
const REENTRY_BLOCK_TIME := 1.0
const SPAWN_FLOOR_Y := 350.0
const PLAYER_HALF_WIDTH := 11.0

var _config: GameConfig
var _screens: Dictionary = {}
var current_screen_id: String = ""


func configure(config: GameConfig) -> void:
	reset()
	_config = config
	_load_screen_registry(config.levels_path)


func reset() -> void:
	_config = null
	_screens.clear()
	current_screen_id = ""


func get_start_screen_id() -> String:
	if _config:
		return _config.starting_screen_id
	return ""


func load_screen(
	screen_id: String,
	container: Node2D,
	player: Node2D,
	defer_player_entered: bool = false
) -> void:
	if not _screens.has(screen_id):
		push_error("ScreenManager: unknown screen '%s'." % screen_id)
		return

	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	current_screen_id = screen_id
	var packed: PackedScene = _screens[screen_id]
	var instance: Node2D = packed.instantiate()
	container.add_child(instance)

	if (
		not defer_player_entered
		and is_instance_valid(player)
		and player.has_method("on_screen_entered")
	):
		player.call("on_screen_entered", screen_id)

	screen_changed.emit(screen_id)


func transition_to(
	target_id: String,
	spawn_position: Vector2,
	container: Node2D,
	player: Node2D,
	block_edge: String = ""
) -> void:
	if not _screens.has(target_id):
		push_error("ScreenManager: unknown screen '%s'." % target_id)
		return

	load_screen(target_id, container, player, true)
	player.global_position = Vector2(spawn_position.x, SPAWN_FLOOR_Y)
	_reset_player_motion(player)
	if not block_edge.is_empty():
		_block_reentry(player, block_edge)
	if player.has_method("on_screen_entered"):
		player.call("on_screen_entered", target_id)


func try_edge_transition(player: Node2D, container: Node2D) -> void:
	if current_screen_id.is_empty() or not _screens.has(current_screen_id):
		return

	if container.get_child_count() == 0:
		return

	var screen_node := container.get_child(0)
	if not screen_node.has_method("get_exits"):
		return

	var exits: Dictionary = screen_node.call("get_exits")
	var pos := player.global_position

	if pos.x <= EDGE_MARGIN and exits.has("left") and not _edge_blocked(player, "left"):
		_transition("left", exits["left"], player, container)
	elif pos.x >= SCREEN_WIDTH - EDGE_MARGIN and exits.has("right") and not _edge_blocked(player, "right"):
		_transition("right", exits["right"], player, container)


func try_directional_transition(player: CharacterBody2D, container: Node2D) -> bool:
	if current_screen_id.is_empty() or container.get_child_count() == 0:
		return false

	var screen_node := container.get_child(0)
	if not screen_node.has_method("get_exits"):
		return false

	var exits: Dictionary = screen_node.call("get_exits")
	var pos := player.global_position

	if Input.is_action_just_pressed("move_up") and exits.has("up") and not _edge_blocked(player, "up"):
		if screen_node.has_method("point_in_up_exit_zone") and screen_node.call("point_in_up_exit_zone", pos):
			_transition("up", exits["up"], player, container, false)
			return true

	if Input.is_action_just_pressed("move_down") and exits.has("down") and not _edge_blocked(player, "down"):
		if not player.is_on_floor():
			return false
		if screen_node.has_method("point_in_down_exit_zone") and screen_node.call("point_in_down_exit_zone", pos):
			if not _can_use_down_exit(exits["down"], player):
				return false
			_transition("down", exits["down"], player, container, false)
			return true

	return false


func _can_use_down_exit(target_id: String, _player: CharacterBody2D) -> bool:
	if target_id == "underwater_shallow" and not Inventory.has_item("snorkel"):
		return false
	return true


func clamp_player_to_bounds(player: Node2D, container: Node2D) -> void:
	if current_screen_id.is_empty() or container.get_child_count() == 0:
		return

	var screen_node := container.get_child(0)
	if not screen_node.has_method("get_exits"):
		return

	var exits: Dictionary = screen_node.call("get_exits")
	var pos := player.global_position
	var min_x := 0.0
	var max_x := SCREEN_WIDTH

	if not exits.has("left"):
		min_x = EDGE_MARGIN + PLAYER_HALF_WIDTH
	if not exits.has("right"):
		max_x = SCREEN_WIDTH - EDGE_MARGIN - PLAYER_HALF_WIDTH

	var clamped_x := clampf(pos.x, min_x, max_x)
	if clamped_x == pos.x:
		return

	player.global_position.x = clamped_x

	if player is CharacterBody2D:
		if not exits.has("left") and player.velocity.x < 0.0:
			player.velocity.x = 0.0
		if not exits.has("right") and player.velocity.x > 0.0:
			player.velocity.x = 0.0


func _transition(
	direction: String,
	target_id: String,
	player: Node2D,
	container: Node2D,
	block_reentry: bool = true
) -> void:
	var entry_x := player.global_position.x
	var entry_y := player.global_position.y
	load_screen(target_id, container, player, true)

	var spawn := Vector2(-1.0, -1.0)
	if container.get_child_count() > 0:
		var screen_node := container.get_child(0)
		if screen_node.has_method("get_spawn_for_entry"):
			spawn = screen_node.call("get_spawn_for_entry", direction, entry_y)

	if spawn.x >= 0.0:
		player.global_position = spawn
		if direction == "left" or direction == "right":
			player.global_position.y = SPAWN_FLOOR_Y
		elif direction == "up" or direction == "down":
			player.global_position.y = spawn.y if spawn.y >= 0.0 else SPAWN_FLOOR_Y
	else:
		match direction:
			"left":
				player.global_position.x = SCREEN_WIDTH - EDGE_MARGIN - SPAWN_INSET
				player.global_position.y = SPAWN_FLOOR_Y
			"right":
				player.global_position.x = EDGE_MARGIN + SPAWN_INSET
				player.global_position.y = SPAWN_FLOOR_Y
			"up":
				player.global_position.y = SCREEN_HEIGHT - EDGE_MARGIN - SPAWN_INSET
				player.global_position.x = entry_x
			"down":
				player.global_position.y = EDGE_MARGIN + SPAWN_INSET
				player.global_position.x = entry_x

	_reset_player_motion(player)

	if block_reentry:
		match direction:
			"left":
				_block_reentry(player, "right")
			"right":
				_block_reentry(player, "left")
			"up":
				_block_reentry(player, "down")
			"down":
				_block_reentry(player, "up")

	if player.has_method("on_screen_entered"):
		player.call("on_screen_entered", target_id)


func _edge_blocked(player: Node2D, edge: String) -> bool:
	return player.has_method("is_edge_blocked") and player.call("is_edge_blocked", edge)


func _block_reentry(player: Node2D, edge: String) -> void:
	if player.has_method("block_edge"):
		player.call("block_edge", edge, REENTRY_BLOCK_TIME)


func _reset_player_motion(player: Node2D) -> void:
	if player is CharacterBody2D:
		player.velocity = Vector2.ZERO


func _load_screen_registry(levels_path: String) -> void:
	var dir := DirAccess.open(levels_path)
	if dir == null:
		push_error("ScreenManager: cannot open levels path '%s'." % levels_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var screen_id := file_name.get_basename()
			var full_path := levels_path.path_join(file_name)
			_screens[screen_id] = load(full_path) as PackedScene
		file_name = dir.get_next()
	dir.list_dir_end()
