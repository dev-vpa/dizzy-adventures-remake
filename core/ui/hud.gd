extends CanvasLayer

## In-game HUD: title, lives, inventory slots, menu. Touch-friendly slot taps + Drop/Use on mobile.

var _slot_buttons: Array[Button] = []
var _slot_icons: Array[ItemSprite] = []
var _slot_empty_labels: Array[Label] = []
var _is_touch: bool = false
var _hud_panel: PanelContainer


func _ready() -> void:
	_is_touch = PlatformUI.is_touch_device()
	_hud_panel = $Root/HudPanel
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
	_hud_panel.size = min_size
	_hud_panel.position = Vector2(8.0, 8.0)


func _build_slots() -> void:
	var container: HBoxContainer = $Root/HudPanel/VBox/InventoryRow/Slots
	for child in container.get_children():
		child.queue_free()
	_slot_buttons.clear()
	_slot_icons.clear()
	_slot_empty_labels.clear()

	var slot_size := Vector2(30, 30)
	if _is_touch:
		slot_size = Vector2(PlatformUI.MIN_TOUCH_SIZE, PlatformUI.MIN_TOUCH_SIZE)

	for i in Inventory.max_slots:
		var slot_btn := Button.new()
		slot_btn.flat = true
		slot_btn.focus_mode = Control.FOCUS_NONE
		slot_btn.custom_minimum_size = slot_size
		slot_btn.add_theme_stylebox_override("normal", _make_slot_style(false))
		slot_btn.add_theme_stylebox_override("hover", _make_slot_style(true))
		slot_btn.add_theme_stylebox_override("pressed", _make_slot_style(true))
		slot_btn.pressed.connect(_on_slot_pressed.bind(i))

		var center := CenterContainer.new()
		center.custom_minimum_size = slot_size - Vector2(4, 4)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_btn.add_child(center)

		var icon := ItemSprite.new()
		icon.bob_enabled = false
		icon.scale = Vector2(0.85, 0.85)
		icon.visible = false
		center.add_child(icon)

		var empty_mark := Label.new()
		empty_mark.text = str(i + 1)
		empty_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_mark.add_theme_color_override("font_color", Color(0.42, 0.38, 0.32, 1.0))
		empty_mark.add_theme_font_size_override("font_size", 10)
		empty_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		center.add_child(empty_mark)

		container.add_child(slot_btn)
		_slot_buttons.append(slot_btn)
		_slot_icons.append(icon)
		_slot_empty_labels.append(empty_mark)

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
		var empty_mark := _slot_empty_labels[i]
		var is_selected := i == selected and not items.is_empty()
		btn.add_theme_stylebox_override("normal", _make_slot_style(is_selected))
		if i < items.size():
			icon.configure(items[i])
			icon.visible = true
			empty_mark.visible = false
		else:
			icon.visible = false
			empty_mark.visible = true

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
			var name := ItemCatalog.get_display_name(Inventory.get_selected_item())
			summary.text = "Held: %s" % name
	elif items.is_empty():
		summary.text = "Tab · R drop · U use"
	else:
		var name := ItemCatalog.get_display_name(Inventory.get_selected_item())
		summary.text = "Held: %s · Tab/R/U" % name


func _refresh_lives() -> void:
	var label: Label = $Root/HudPanel/VBox/HeaderRow/LivesLabel
	var heart := "♥" if Lives.current_lives == 1 else "♥".repeat(Lives.current_lives)
	label.text = heart


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
