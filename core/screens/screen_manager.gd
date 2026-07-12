extends Node

## Flick-screen navigation: one active screen at a time, edge transitions.

signal screen_changed(screen_id: String)

const SCREEN_WIDTH := 512
const SCREEN_HEIGHT := 384
const EDGE_MARGIN := 8.0

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


func load_screen(screen_id: String, container: Node2D, player: Node2D) -> void:
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

	if is_instance_valid(player) and player.has_method("on_screen_entered"):
		player.call("on_screen_entered", screen_id)

	screen_changed.emit(screen_id)


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

	if pos.x <= EDGE_MARGIN and exits.has("left"):
		_transition("left", exits["left"], player, container)
	elif pos.x >= SCREEN_WIDTH - EDGE_MARGIN and exits.has("right"):
		_transition("right", exits["right"], player, container)
	elif pos.y <= EDGE_MARGIN and exits.has("up"):
		_transition("up", exits["up"], player, container)
	elif pos.y >= SCREEN_HEIGHT - EDGE_MARGIN and exits.has("down"):
		_transition("down", exits["down"], player, container)


func _transition(direction: String, target_id: String, player: Node2D, container: Node2D) -> void:
	load_screen(target_id, container, player)
	match direction:
		"left":
			player.global_position.x = SCREEN_WIDTH - EDGE_MARGIN - 1.0
		"right":
			player.global_position.x = EDGE_MARGIN + 1.0
		"up":
			player.global_position.y = SCREEN_HEIGHT - EDGE_MARGIN - 1.0
		"down":
			player.global_position.y = EDGE_MARGIN + 1.0


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
