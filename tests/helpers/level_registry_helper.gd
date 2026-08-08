class_name LevelRegistryHelper
extends RefCounted

## Lists level scenes and reads GameScreen exits without ScreenManager internals.


static func list_screen_ids(levels_path: String) -> Array[String]:
	var ids: Array[String] = []
	var dir := DirAccess.open(levels_path)
	if dir == null:
		return ids
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			ids.append(file_name.get_basename())
		file_name = dir.get_next()
	dir.list_dir_end()
	ids.sort()
	return ids


static func get_exits(screen_id: String, levels_path: String) -> Dictionary:
	var path := levels_path.path_join("%s.tscn" % screen_id)
	if not ResourceLoader.exists(path):
		return {}
	var packed: PackedScene = load(path)
	if packed == null:
		return {}
	var instance: Node = packed.instantiate()
	if not instance.has_method("get_exits"):
		instance.free()
		return {}
	var exits: Dictionary = instance.call("get_exits")
	_collect_door_targets(instance, exits)
	instance.free()
	return exits


static func _collect_door_targets(node: Node, exits: Dictionary) -> void:
	if "target_screen_id" in node:
		var target: String = str(node.get("target_screen_id"))
		if not target.is_empty():
			var key := "door_%s" % target
			exits[key] = target
	for child in node.get_children():
		_collect_door_targets(child, exits)


static func reachable_from(start_id: String, levels_path: String) -> Array[String]:
	var known := list_screen_ids(levels_path)
	if start_id not in known:
		return []
	var visited: Dictionary = {start_id: true}
	var queue: Array[String] = [start_id]
	while not queue.is_empty():
		var current: String = queue.pop_front()
		var exits: Dictionary = get_exits(current, levels_path)
		for direction in exits:
			var target: String = exits[direction]
			if target.is_empty() or target in visited:
				continue
			if target not in known:
				continue
			visited[target] = true
			queue.append(target)
	var result: Array[String] = []
	for id in visited:
		result.append(id)
	result.sort()
	return result
