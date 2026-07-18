extends RefCounted
class_name TiItems

## Loads Treasure Island item metadata from games/treasure-island/data/items.json.

const DATA_PATH := "res://games/treasure-island/data/items.json"

static var _cache: Dictionary = {}


static func load_data() -> Dictionary:
	if not _cache.is_empty():
		return _cache
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("TiItems: cannot open %s" % DATA_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("TiItems: invalid JSON in %s" % DATA_PATH)
		return {}
	_cache = parsed
	return _cache


static func get_item(item_id: String) -> Dictionary:
	for entry: Dictionary in load_data().get("items", []):
		if entry.get("id", "") == item_id:
			return entry
	return {}


static func get_display_name(item_id: String) -> String:
	var entry := get_item(item_id)
	if entry.is_empty():
		return ItemCatalog.get_display_name(item_id)
	return entry.get("display_name", item_id)
