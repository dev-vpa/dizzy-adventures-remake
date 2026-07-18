extends Node

## Tracks world pickups and puzzle flags for the current run.

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


func get_flag(flag_id: String) -> bool:
	if flag_id.is_empty():
		return false
	return _flags.get(flag_id, false)


func clear_flag(flag_id: String) -> void:
	_flags.erase(flag_id)
