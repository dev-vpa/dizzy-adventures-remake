extends CanvasLayer

## In-game HUD: game title, inventory, return to menu.


func _ready() -> void:
	if GameManager.active_config:
		$Root/HudPanel/Margin/VBox/TitleLabel.text = GameManager.active_config.title
	Inventory.inventory_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var label: Label = $Root/HudPanel/Margin/VBox/InventoryLabel
	var items := Inventory.get_items()
	var max_slots := Inventory.max_slots
	if items.is_empty():
		label.text = "Inventory: (empty)  [%d/%d]" % [0, max_slots]
	else:
		label.text = "Inventory: %s  [%d/%d]" % [", ".join(items), items.size(), max_slots]


func _on_menu_pressed() -> void:
	GameManager.quit_to_main_menu()
