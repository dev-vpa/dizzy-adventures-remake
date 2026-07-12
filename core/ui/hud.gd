extends CanvasLayer

## In-game HUD: title, lives, inventory slots, menu.

var _slot_panels: Array[PanelContainer] = []
var _slot_icons: Array[ItemSprite] = []


func _ready() -> void:
	if GameManager.active_config:
		$Root/HudPanel/Margin/VBox/TitleLabel.text = GameManager.active_config.title
	_build_slots()
	Inventory.inventory_changed.connect(_refresh)
	Inventory.selection_changed.connect(_refresh)
	Lives.lives_changed.connect(_refresh_lives)
	_refresh()
	_refresh_lives()


func _build_slots() -> void:
	var container: HBoxContainer = $Root/HudPanel/Margin/VBox/Slots
	for child in container.get_children():
		child.queue_free()
	_slot_panels.clear()
	_slot_icons.clear()

	for i in Inventory.max_slots:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(26, 26)
		panel.add_theme_stylebox_override("panel", _make_slot_style(false))

		var center := CenterContainer.new()
		center.custom_minimum_size = Vector2(26, 26)
		panel.add_child(center)

		var icon := ItemSprite.new()
		icon.bob_enabled = false
		icon.scale = Vector2(0.85, 0.85)
		icon.visible = false
		center.add_child(icon)

		container.add_child(panel)
		_slot_panels.append(panel)
		_slot_icons.append(icon)


func _make_slot_style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.14, 0.95)
	style.border_color = Color(0.55, 0.48, 0.38, 1.0) if not selected else Color(1.0, 0.88, 0.35, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(3)
	return style


func _refresh() -> void:
	var items := Inventory.get_items()
	var selected := Inventory.selected_index
	for i in _slot_icons.size():
		var icon := _slot_icons[i]
		var panel := _slot_panels[i]
		panel.add_theme_stylebox_override("panel", _make_slot_style(i == selected and not items.is_empty()))
		if i < items.size():
			icon.configure(items[i])
			icon.visible = true
		else:
			icon.visible = false

	var summary: Label = $Root/HudPanel/Margin/VBox/InventoryLabel
	if items.is_empty():
		summary.text = "Tab — select  ·  R — drop  ·  U — use"
	else:
		var name := ItemCatalog.get_display_name(Inventory.get_selected_item())
		summary.text = "Held: %s  ·  Tab / R / U" % name


func _refresh_lives() -> void:
	var label: Label = $Root/HudPanel/Margin/VBox/LivesLabel
	var heart := "♥" if Lives.current_lives == 1 else "♥".repeat(Lives.current_lives)
	label.text = "Lives: %s" % heart


func _on_menu_pressed() -> void:
	GameManager.quit_to_main_menu()
