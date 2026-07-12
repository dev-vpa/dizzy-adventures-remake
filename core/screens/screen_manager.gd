extends Node

## Flick-screen navigation: one active screen at a time, edge transitions.

signal screen_changed(screen_id: String)

const SCREEN_WIDTH := 512
const SCREEN_HEIGHT := 384
const EDGE_MARGIN := 8.0
const SPAWN_INSET := 24.0
const REENTRY_BLOCK_TIME := 1.0

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
	player.global_position = spawn_position
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
	elif pos.y <= EDGE_MARGIN and exits.has("up") and not _edge_blocked(player, "up"):
		_transition("up", exits["up"], player, container)
	elif pos.y >= SCREEN_HEIGHT - EDGE_MARGIN and exits.has("down") and not _edge_blocked(player, "down"):
		_transition("down", exits["down"], player, container)


func _transition(direction: String, target_id: String, player: Node2D, container: Node2D) -> void:
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
	else:
		match direction:
			"left":
				player.global_position.x = SCREEN_WIDTH - EDGE_MARGIN - SPAWN_INSET
				player.global_position.y = entry_y
			"right":
				player.global_position.x = EDGE_MARGIN + SPAWN_INSET
				player.global_position.y = entry_y
			"up":
				player.global_position.y = SCREEN_HEIGHT - EDGE_MARGIN - SPAWN_INSET
				player.global_position.x = entry_x
			"down":
				player.global_position.y = EDGE_MARGIN + SPAWN_INSET
				player.global_position.x = entry_x

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
