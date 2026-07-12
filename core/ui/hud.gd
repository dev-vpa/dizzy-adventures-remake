extends Control

## In-game HUD: inventory slots and back-to-menu.


func _ready() -> void:
	Inventory.inventory_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var label: RichTextLabel = $MarginContainer/VBox/InventoryLabel
	if label == null:
		return
	var items := Inventory.get_items()
	if items.is_empty():
		label.text = "[b]Inventory:[/b] (empty)"
	else:
		label.text = "[b]Inventory:[/b] " + ", ".join(items)


func _on_back_pressed() -> void:
	GameManager.quit_to_main_menu()
