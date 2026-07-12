extends Node

## Tracks world pickups collected this run so screens can reload without respawning them.

var _collected: Dictionary = {}


func reset() -> void:
	_collected.clear()


func mark_collected(world_id: String) -> void:
	if world_id.is_empty():
		return
	_collected[world_id] = true


func is_collected(world_id: String) -> bool:
	if world_id.is_empty():
		return false
	return _collected.get(world_id, false)
