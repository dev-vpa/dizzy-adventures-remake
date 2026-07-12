extends CanvasLayer

## In-game HUD: title, lives, inventory slots, menu.

const MIN_PANEL_WIDTH := 192.0

var _slot_panels: Array[PanelContainer] = []
var _slot_icons: Array[HudItemIcon] = []
var _is_touch: bool = false
var _hud_panel: PanelContainer


func _ready() -> void:
	_is_touch = PlatformUI.is_touch_device()
	_hud_panel = $Root/HudPanel
	_hud_panel.clip_contents = true
	_hud_panel.custom_minimum_size.x = MIN_PANEL_WIDTH
	if GameManager.active_config:
		$Root/HudPanel/VBox/HeaderRow/TitleLabel.text = GameManager.active_config.title
	$Root/HudPanel/VBox/ActionsHBox.visible = _is_touch
	_build_slots()
	Inventory.inventory_changed.connect(_refresh)
	Inventory.selection_changed.connect(_refresh)
	Lives.lives_changed.connect(_refresh_lives)
	Collectibles.collectibles_changed.connect(_refresh_coins)
	_refresh()
	_refresh_lives()
	_refresh_coins()
	call_deferred("_fit_panel_size")


func _fit_panel_size() -> void:
	if _hud_panel == null:
		return
	var min_size := _hud_panel.get_combined_minimum_size()
	min_size.x = maxf(min_size.x, MIN_PANEL_WIDTH)
	_hud_panel.size = min_size
	_hud_panel.position = Vector2(8.0, 8.0)
	_sync_slot_icon_sizes()


func _slot_size() -> Vector2:
	var side := 28.0
	if _is_touch:
		side = PlatformUI.MIN_TOUCH_SIZE
	return Vector2(side, side)


func _build_slots() -> void:
	var container: HBoxContainer = $Root/HudPanel/VBox/InventoryRow/Slots
	for child in container.get_children():
		child.queue_free()
	_slot_panels.clear()
	_slot_icons.clear()

	var slot_size := _slot_size()

	for i in Inventory.max_slots:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = slot_size
		slot.clip_contents = true
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		slot.add_theme_stylebox_override("panel", _make_slot_style(false))
		slot.gui_input.connect(_on_slot_gui_input.bind(i))

		var icon := HudItemIcon.new()
		icon.custom_minimum_size = slot_size
		icon.size = slot_size
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_empty_label(str(i + 1))
		slot.add_child(icon)

		container.add_child(slot)
		_slot_panels.append(slot)
		_slot_icons.append(icon)

	call_deferred("_fit_panel_size")


func _sync_slot_icon_sizes() -> void:
	var slot_size := _slot_size()
	for i in _slot_icons.size():
		_slot_panels[i].custom_minimum_size = slot_size
		_slot_icons[i].custom_minimum_size = slot_size
		_slot_icons[i].size = slot_size
		_slot_icons[i].queue_redraw()


func _make_slot_style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.16, 0.98)
	style.border_color = Color(0.62, 0.54, 0.4, 1.0) if not selected else Color(1.0, 0.88, 0.35, 1.0)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(4)
	return style


func _refresh() -> void:
	var items := Inventory.get_items()
	var selected := Inventory.selected_index
	for i in _slot_icons.size():
		var icon := _slot_icons[i]
		var slot := _slot_panels[i]
		var is_selected := i == selected and not items.is_empty()
		slot.add_theme_stylebox_override("panel", _make_slot_style(is_selected))
		if i < items.size():
			icon.configure(items[i])
		else:
			icon.configure("")
			icon.set_empty_label(str(i + 1))

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
	if items.is_empty():
		summary.text = PlatformUI.hint_text("Tab · R drop · U use", "Tap slot · Drop / Use")
	else:
		var held := ItemCatalog.get_display_name(Inventory.get_selected_item())
		summary.text = PlatformUI.hint_text(
			"Held: %s · Tab/R/U" % held,
			"Held: %s" % held
		)


func _refresh_lives() -> void:
	var hearts := ""
	for i in Lives.current_lives:
		hearts += "♥"
	if hearts.is_empty():
		hearts = "♡"
	$Root/HudPanel/VBox/HeaderRow/LivesLabel.text = hearts


func _refresh_coins() -> void:
	var coins_label: Label = $Root/HudPanel/VBox/CoinsLabel
	if Collectibles.total <= 0:
		coins_label.visible = false
		return
	coins_label.visible = true
	coins_label.text = Collectibles.get_label()
	call_deferred("_fit_panel_size")


func _get_player() -> CharacterBody2D:
	var nodes := get_tree().get_nodes_in_group("player")
	if nodes.is_empty():
		return null
	return nodes[0] as CharacterBody2D


func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
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
