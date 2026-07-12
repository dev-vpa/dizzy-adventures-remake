extends Node

## Treasure Island gameplay hooks (item use, future puzzle logic).

func _ready() -> void:
	Inventory.item_used.connect(_on_item_used)


func _on_item_used(item_id: String) -> void:
	match item_id:
		"snorkel":
			# Snorkel protection is inventory-based; sprite redraws via Inventory signal.
			pass
		_:
			pass
