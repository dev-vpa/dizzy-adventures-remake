extends Node

## Inventory with configurable slot count per game.

signal inventory_changed
signal selection_changed
signal item_used(item_id: String)

var max_slots: int = 1
var selected_index: int = 0
var _items: Array[String] = []


func configure(slots: int) -> void:
	max_slots = maxi(slots, 1)
	clear()


func clear() -> void:
	_items.clear()
	selected_index = 0
	inventory_changed.emit()
	selection_changed.emit()


func has_item(item_id: String) -> bool:
	return _items.has(item_id)


func is_full() -> bool:
	return _items.size() >= max_slots


func get_items() -> Array[String]:
	return _items.duplicate()


func get_selected_item() -> String:
	if _items.is_empty():
		return ""
	selected_index = clampi(selected_index, 0, _items.size() - 1)
	return _items[selected_index]


func select_next() -> void:
	if _items.is_empty():
		selected_index = 0
	else:
		selected_index = (selected_index + 1) % _items.size()
	selection_changed.emit()


func select_index(index: int) -> bool:
	if index < 0 or index >= _items.size():
		return false
	selected_index = index
	selection_changed.emit()
	return true


func try_pick_up(item_id: String) -> bool:
	if item_id.is_empty() or has_item(item_id):
		return false
	if is_full():
		return false
	_items.append(item_id)
	if _items.size() == 1:
		selected_index = 0
	inventory_changed.emit()
	return true


func try_drop_selected() -> String:
	if _items.is_empty():
		return ""
	selected_index = clampi(selected_index, 0, _items.size() - 1)
	var item_id := _items[selected_index]
	_items.remove_at(selected_index)
	if _items.is_empty():
		selected_index = 0
	elif selected_index >= _items.size():
		selected_index = _items.size() - 1
	inventory_changed.emit()
	selection_changed.emit()
	return item_id


func try_use_selected() -> bool:
	var item_id := get_selected_item()
	if item_id.is_empty():
		return false
	item_used.emit(item_id)
	return true
