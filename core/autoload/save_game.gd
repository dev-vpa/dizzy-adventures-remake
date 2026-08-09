extends Node

## Single-slot save per game id (ConfigFile under user://).

const SCHEMA_VERSION := 2
const SAVE_DIR := "user://saves"

signal save_changed

## Runtime ground drops: screen_id -> Array[{uid, item_id, x, y}]
var _ground_items: Dictionary = {}
var _pending_restore := false
var _restore_screen := ""
var _restore_pos := Vector2(512, 700)
var _suppress_autosave := false


func _ready() -> void:
	ScreenManager.screen_changed.connect(_on_screen_changed)
	WorldState.flag_changed.connect(_on_flag_changed)


func _on_screen_changed(_screen_id: String) -> void:
	var tree := get_tree()
	if tree:
		var world := tree.get_first_node_in_group("game_world")
		if world != null and world.get("screen_container") != null:
			apply_ground_items(world.screen_container)
	request_save()


func _on_flag_changed(_flag_id: String, _value: bool) -> void:
	request_save()


func save_path(game_id: String) -> String:
	return "%s/%s.cfg" % [SAVE_DIR, game_id]


func has_save(game_id: String) -> bool:
	if game_id.is_empty():
		return false
	return FileAccess.file_exists(save_path(game_id))


func delete_save(game_id: String) -> void:
	var path := save_path(game_id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	_ground_items.clear()
	_pending_restore = false
	save_changed.emit()


func clear_runtime() -> void:
	_ground_items.clear()
	_pending_restore = false
	_restore_screen = ""


func request_save(game_id: String = "") -> void:
	if _suppress_autosave:
		return
	if GameManager.state != GameManager.State.PLAYING:
		return
	var gid := game_id
	if gid.is_empty() and GameManager.active_config:
		gid = GameManager.active_config.id
	if gid.is_empty():
		return
	_write_save(gid)


func begin_new_game(game_id: String) -> void:
	delete_save(game_id)
	clear_runtime()


func begin_continue(game_id: String) -> bool:
	if not has_save(game_id):
		return false
	_suppress_autosave = true
	var ok := _read_save(game_id)
	_suppress_autosave = false
	return ok


func consume_restore() -> Dictionary:
	if not _pending_restore:
		return {}
	_pending_restore = false
	return {
		"screen_id": _restore_screen,
		"position": _restore_pos,
	}


func record_drop(screen_id: String, item_id: String, pos: Vector2) -> String:
	if screen_id.is_empty() or item_id.is_empty():
		return ""
	var uid := "%s_%d" % [Time.get_ticks_msec(), randi() % 100000]
	if not _ground_items.has(screen_id):
		_ground_items[screen_id] = []
	(_ground_items[screen_id] as Array).append({
		"uid": uid,
		"item_id": item_id,
		"x": pos.x,
		"y": pos.y,
	})
	request_save()
	return uid


func remove_ground_uid(uid: String) -> void:
	if uid.is_empty():
		return
	for screen_id in _ground_items.keys():
		var arr: Array = _ground_items[screen_id]
		for i in range(arr.size() - 1, -1, -1):
			var entry: Dictionary = arr[i]
			if str(entry.get("uid", "")) == uid:
				arr.remove_at(i)
	request_save()


func apply_ground_items(container: Node2D) -> void:
	if container == null or container.get_child_count() == 0:
		return
	var screen_id := ScreenManager.current_screen_id
	if screen_id.is_empty() or not _ground_items.has(screen_id):
		return
	var screen := container.get_child(0) as Node2D
	if screen == null:
		return
	const PickupScene := preload("res://core/items/pickup_item.tscn")
	for entry in _ground_items[screen_id]:
		var uid := str(entry.get("uid", ""))
		var item_id := str(entry.get("item_id", ""))
		if uid.is_empty() or item_id.is_empty():
			continue
		var world_id := "drop/%s" % uid
		if WorldState.is_collected(world_id):
			continue
		var pickup: Area2D = PickupScene.instantiate()
		pickup.item_id = item_id
		pickup.display_name = ItemCatalog.get_display_name(item_id)
		pickup.world_id = world_id
		pickup.set_meta("ground_uid", uid)
		screen.add_child(pickup)
		pickup.global_position = Vector2(float(entry.get("x", 512)), float(entry.get("y", 680)))


func _write_save(game_id: String) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "schema", SCHEMA_VERSION)
	cfg.set_value("meta", "game_id", game_id)
	cfg.set_value("meta", "saved_at", Time.get_unix_time_from_system())

	cfg.set_value("progress", "screen_id", ScreenManager.current_screen_id)
	var player := get_tree().get_first_node_in_group("player") if get_tree() else null
	var pos := Vector2(512, 700)
	if player is Node2D:
		pos = (player as Node2D).global_position
	cfg.set_value("progress", "pos_x", pos.x)
	cfg.set_value("progress", "pos_y", pos.y)
	cfg.set_value("progress", "lives", Lives.current_lives)
	cfg.set_value("progress", "coins", Collectibles.collected)

	cfg.set_value("inventory", "items", ",".join(PackedStringArray(Inventory.get_items())))
	cfg.set_value("inventory", "selected", Inventory.selected_index)

	cfg.set_value("world", "flags", ",".join(WorldState.get_flag_ids()))
	cfg.set_value("world", "collected", ",".join(WorldState.get_collected_ids()))

	var ground_lines: PackedStringArray = []
	for screen_id in _ground_items.keys():
		for entry in _ground_items[screen_id]:
			ground_lines.append(
				"%s|%s|%s|%s|%s"
				% [
					screen_id,
					str(entry.get("uid", "")),
					str(entry.get("item_id", "")),
					str(entry.get("x", 0.0)),
					str(entry.get("y", 0.0)),
				]
			)
	cfg.set_value("ground", "items", "\n".join(ground_lines))

	var err := cfg.save(save_path(game_id))
	if err != OK:
		push_warning("SaveGame: failed to save (%s)" % err)
	else:
		save_changed.emit()


func _read_save(game_id: String) -> bool:
	var cfg := ConfigFile.new()
	var err := cfg.load(save_path(game_id))
	if err != OK:
		return false
	if int(cfg.get_value("meta", "schema", 0)) != SCHEMA_VERSION:
		push_warning("SaveGame: unsupported schema")
		return false

	WorldState.load_state(
		_split_csv(str(cfg.get_value("world", "flags", ""))),
		_split_csv(str(cfg.get_value("world", "collected", "")))
	)
	Collectibles.set_collected(int(cfg.get_value("progress", "coins", 0)))
	Lives.current_lives = int(cfg.get_value("progress", "lives", Lives.max_lives))
	Lives.lives_changed.emit()

	var items := _split_csv(str(cfg.get_value("inventory", "items", "")))
	Inventory.load_items(items, int(cfg.get_value("inventory", "selected", 0)))

	_ground_items.clear()
	var ground_blob := str(cfg.get_value("ground", "items", ""))
	for line in ground_blob.split("\n", false):
		var parts := line.split("|")
		if parts.size() < 5:
			continue
		var screen_id := parts[0]
		if not _ground_items.has(screen_id):
			_ground_items[screen_id] = []
		(_ground_items[screen_id] as Array).append({
			"uid": parts[1],
			"item_id": parts[2],
			"x": float(parts[3]),
			"y": float(parts[4]),
		})

	_restore_screen = str(cfg.get_value("progress", "screen_id", "beach_start"))
	_restore_pos = Vector2(
		float(cfg.get_value("progress", "pos_x", 512.0)),
		float(cfg.get_value("progress", "pos_y", 700.0))
	)
	_pending_restore = not _restore_screen.is_empty()
	return true


func _split_csv(text: String) -> PackedStringArray:
	if text.is_empty():
		return PackedStringArray()
	return text.split(",", false)
