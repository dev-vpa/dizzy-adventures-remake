extends CanvasLayer

## In-game HUD: title, lives, inventory slots, menu.

var _slot_buttons: Array[Button] = []
var _slot_icons: Array[HudItemIcon] = []
var _is_touch: bool = false
var _hud_panel: PanelContainer


func _ready() -> void:
	_is_touch = PlatformUI.is_touch_device()
	_hud_panel = $Root/HudPanel
	_hud_panel.clip_contents = true
	if GameManager.active_config:
		$Root/HudPanel/VBox/HeaderRow/TitleLabel.text = GameManager.active_config.title
	$Root/HudPanel/VBox/ActionsHBox.visible = _is_touch
	_build_slots()
	Inventory.inventory_changed.connect(_refresh)
	Inventory.selection_changed.connect(_refresh)
	Lives.lives_changed.connect(_refresh_lives)
	_refresh()
	_refresh_lives()
	call_deferred("_fit_panel_size")


func _fit_panel_size() -> void:
	if _hud_panel == null:
		return
	var min_size := _hud_panel.get_combined_minimum_size()
	if min_size.x > 4.0 and min_size.y > 4.0:
		_hud_panel.size = min_size
		_hud_panel.position = Vector2(8.0, 8.0)


func _build_slots() -> void:
	var container: HBoxContainer = $Root/HudPanel/VBox/InventoryRow/Slots
	for child in container.get_children():
		child.queue_free()
	_slot_buttons.clear()
	_slot_icons.clear()

	var slot_size := Vector2(28, 28)
	if _is_touch:
		slot_size = Vector2(PlatformUI.MIN_TOUCH_SIZE, PlatformUI.MIN_TOUCH_SIZE)

	for i in Inventory.max_slots:
		var slot_btn := Button.new()
		slot_btn.flat = true
		slot_btn.focus_mode = Control.FOCUS_NONE
		slot_btn.clip_contents = true
		slot_btn.custom_minimum_size = slot_size
		slot_btn.add_theme_stylebox_override("normal", _make_slot_style(false))
		slot_btn.add_theme_stylebox_override("hover", _make_slot_style(true))
		slot_btn.add_theme_stylebox_override("pressed", _make_slot_style(true))
		slot_btn.pressed.connect(_on_slot_pressed.bind(i))

		var icon := HudItemIcon.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = slot_size - Vector2(2, 2)
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		icon.set_empty_label(str(i + 1))
		slot_btn.add_child(icon)

		container.add_child(slot_btn)
		_slot_buttons.append(slot_btn)
		_slot_icons.append(icon)

	call_deferred("_fit_panel_size")


func _make_slot_style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.16, 0.98)
	style.border_color = Color(0.62, 0.54, 0.4, 1.0) if not selected else Color(1.0, 0.88, 0.35, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(3)
	return style


func _refresh() -> void:
	var items := Inventory.get_items()
	var selected := Inventory.selected_index
	for i in _slot_icons.size():
		var icon := _slot_icons[i]
		var btn := _slot_buttons[i]
		var is_selected := i == selected and not items.is_empty()
		btn.add_theme_stylebox_override("normal", _make_slot_style(is_selected))
		if i < items.size():
			icon.configure(items[i])
		else:
			icon.configure("")

	_update_action_buttons()
	_update_hint(items)
	call_deferred("_fit_panel_size")


func _update_action_buttons() -> void:
	if not _is_touch:
		return
	var has_item := not Inventory.get_items().is_empty()
	$Root/HudPanel/VBox/ActionsHBox/DropButton.disabled = not has_item
	$Root/HudPanel/VBox/ActionsHBox/UseButton.disabled = not has_item


func _update_hint(items: Array[String]) -> void:
	var summary: Label = $Root/HudPanel/VBox/InventoryLabel
	if _is_touch:
		if items.is_empty():
			summary.text = "Tap slot · Drop / Use"
		else:
			summary.text = "Held: %s" % ItemCatalog.get_display_name(Inventory.get_selected_item())
	elif items.is_empty():
		summary.text = "Tab · R drop · U use"
	else:
		summary.text = "Held: %s · Tab/R/U" % ItemCatalog.get_display_name(Inventory.get_selected_item())


func _refresh_lives() -> void:
	$Root/HudPanel/VBox/HeaderRow/LivesLabel.text = "♥"


func _get_player() -> CharacterBody2D:
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.is_empty():
		return null
	return nodes[0] as CharacterBody2D


func _on_slot_pressed(index: int) -> void:
	Inventory.select_index(index)


func _on_drop_pressed() -> void:
	var player := _get_player()
	if player and player.has_method("drop_item"):
		player.drop_item()


func _on_use_pressed() -> void:
	var player := _get_player()
	if player and player.has_method("use_item"):
		player.use_item()


func _on_menu_pressed() -> void:
	GameManager.quit_to_main_menu()
