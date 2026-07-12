extends Node

## Inventory with configurable slot count per game.

signal inventory_changed

var max_slots: int = 1
var _items: Array[String] = []


func configure(slots: int) -> void:
	max_slots = maxi(slots, 1)
	clear()


func clear() -> void:
	_items.clear()
	inventory_changed.emit()


func has_item(item_id: String) -> bool:
	return _items.has(item_id)


func is_full() -> bool:
	return _items.size() >= max_slots


func get_items() -> Array[String]:
	return _items.duplicate()


func try_pick_up(item_id: String) -> bool:
	if item_id.is_empty() or has_item(item_id):
		return false
	if is_full():
		return false
	_items.append(item_id)
	inventory_changed.emit()
	return true


func try_drop(item_id: String) -> bool:
	var index := _items.find(item_id)
	if index == -1:
		return false
	_items.remove_at(index)
	inventory_changed.emit()
	return true
