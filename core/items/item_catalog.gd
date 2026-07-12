class_name ItemCatalog
extends RefCounted

## Display names and metadata for pickup items (expand per game in Phase 2+).

const DISPLAY_NAMES: Dictionary = {
	"snorkel": "Snorkel",
	"coin": "Coin",
}

const ICON_IDS: Dictionary = {
	"snorkel": "snorkel",
	"coin": "coin",
}


static func get_display_name(item_id: String) -> String:
	return DISPLAY_NAMES.get(item_id, item_id.capitalize())


static func get_icon_id(item_id: String) -> String:
	return ICON_IDS.get(item_id, "default")
