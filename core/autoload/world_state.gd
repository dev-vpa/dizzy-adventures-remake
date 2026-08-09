extends Node

## Tracks world pickups and puzzle flags for the current run.

signal flag_changed(flag_id: String, value: bool)

var _collected: Dictionary = {}
var _flags: Dictionary = {}


func reset() -> void:
	_collected.clear()
	_flags.clear()


func mark_collected(world_id: String) -> void:
	if world_id.is_empty():
		return
	_collected[world_id] = true


func is_collected(world_id: String) -> bool:
	if world_id.is_empty():
		return false
	return _collected.get(world_id, false)


func set_flag(flag_id: String, value: bool = true) -> void:
	if flag_id.is_empty():
		return
	_flags[flag_id] = value
	flag_changed.emit(flag_id, value)


func get_flag(flag_id: String) -> bool:
	if flag_id.is_empty():
		return false
	return _flags.get(flag_id, false)


func clear_flag(flag_id: String) -> void:
	if not _flags.has(flag_id):
		return
	_flags.erase(flag_id)
	flag_changed.emit(flag_id, false)


func get_flag_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	for key in _flags.keys():
		if _flags[key]:
			ids.append(str(key))
	ids.sort()
	return ids


func get_collected_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	for key in _collected.keys():
		if _collected[key]:
			ids.append(str(key))
	ids.sort()
	return ids


func load_state(flag_ids: PackedStringArray, collected_ids: PackedStringArray) -> void:
	_flags.clear()
	_collected.clear()
	for flag_id in flag_ids:
		if not str(flag_id).is_empty():
			_flags[str(flag_id)] = true
	for world_id in collected_ids:
		if not str(world_id).is_empty():
			_collected[str(world_id)] = true
