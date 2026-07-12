extends Control

var _time: float = 0.0
var _selected_card: PanelContainer
var _selected_config: GameConfig
var _style_card_normal: StyleBoxFlat
var _style_card_selected: StyleBoxFlat
var _style_card_hover: StyleBoxFlat
var _title: Label
var _description: Label
var _keyboard_hint: Label
var _play_button: Button
var _ui_tween: Tween


func _ready() -> void:
	modulate = Color.WHITE
	_title = $MarginContainer/VBox/Title
	_description = $MarginContainer/VBox/DetailSection/Description
	_keyboard_hint = $ActionsFooter/Margin/VBox/KeyboardHint
	_play_button = $ActionsFooter/Margin/VBox/ActionsRow/PlayButton
	_build_card_styles()
	_populate_cards()
	_apply_touch_layout()
	_apply_keyboard_hint()
	set_process(true)


func _apply_touch_layout() -> void:
	if not PlatformUI.is_touch_device():
		return
	var back: Button = $ActionsFooter/Margin/VBox/ActionsRow/BackButton
	back.custom_minimum_size = Vector2(168, PlatformUI.MIN_TOUCH_SIZE)
	_play_button.custom_minimum_size = Vector2(168, PlatformUI.MIN_TOUCH_SIZE)


func _apply_keyboard_hint() -> void:
	if _keyboard_hint == null:
		return
	_keyboard_hint.visible = not PlatformUI.is_touch_device()


func _process(delta: float) -> void:
	_time += delta
	_pulse_selected_card()
	_animate_title()


func _build_card_styles() -> void:
	_style_card_normal = StyleBoxFlat.new()
	_style_card_normal.bg_color = Color(0.14, 0.11, 0.22, 0.95)
	_style_card_normal.border_color = Color(0.45, 0.4, 0.32, 1.0)
	_style_card_normal.set_border_width_all(2)
	_style_card_normal.set_corner_radius_all(6)
	_style_card_normal.content_margin_left = 10.0
	_style_card_normal.content_margin_top = 8.0
	_style_card_normal.content_margin_right = 12.0
	_style_card_normal.content_margin_bottom = 8.0

	_style_card_selected = _style_card_normal.duplicate() as StyleBoxFlat
	_style_card_selected.bg_color = Color(0.22, 0.16, 0.32, 0.98)
	_style_card_selected.border_color = Color(1.0, 0.88, 0.35, 1.0)

	_style_card_hover = _style_card_normal.duplicate() as StyleBoxFlat
	_style_card_hover.bg_color = Color(0.18, 0.14, 0.28, 0.98)
	_style_card_hover.border_color = Color(0.75, 0.65, 0.45, 1.0)


func _populate_cards() -> void:
	var container: VBoxContainer = $MarginContainer/VBox/GameCards
	for child in container.get_children():
		child.queue_free()

	for config in GameManager.get_available_games():
		container.add_child(_create_game_card(config))

	if container.get_child_count() > 0:
		var first_card := container.get_child(0) as PanelContainer
		first_card.grab_focus()
		_select_card(first_card.get_meta("config"), first_card, false)


func _create_game_card(config: GameConfig) -> PanelContainer:
	var card := PanelContainer.new()
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("panel", _style_card_normal.duplicate())
	card.set_meta("config", config)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var icon := GameSelectIcon.new()
	icon.custom_minimum_size = Vector2(52, 52)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.configure(config)
	row.add_child(icon)
	card.set_meta("icon", icon)

	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", 4)
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_col)

	var title := Label.new()
	title.text = config.title
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1.0))
	title.add_theme_font_size_override("font_size", 16)
	text_col.add_child(title)

	var stats := Label.new()
	stats.text = _format_stats(config)
	stats.add_theme_color_override("font_color", Color(0.78, 0.72, 0.58, 1.0))
	stats.add_theme_font_size_override("font_size", 11)
	text_col.add_child(stats)

	card.gui_input.connect(_on_card_gui_input.bind(config, card))
	card.focus_entered.connect(_on_card_focused.bind(config, card))
	card.mouse_entered.connect(_on_card_hovered.bind(card))
	card.mouse_exited.connect(_on_card_unhovered.bind(card))
	card.resized.connect(_on_card_resized.bind(card))
	return card


func _on_card_resized(card: PanelContainer) -> void:
	card.pivot_offset = card.size * 0.5


func _format_stats(config: GameConfig) -> String:
	var life_word := "life" if config.starting_lives == 1 else "lives"
	var parts: PackedStringArray = [
		"%d %s" % [config.starting_lives, life_word],
		"%d slots" % config.inventory_slots,
	]
	if config.collectible_total > 0 and not config.collectible_name.is_empty():
		parts.append("%d %s" % [config.collectible_total, config.collectible_name])
	return " · ".join(parts)


func _set_card_icon_active(card: PanelContainer, active: bool) -> void:
	var icon: GameSelectIcon = card.get_meta("icon")
	icon.set_active(active)


func _select_card(config: GameConfig, card: PanelContainer, animate: bool = true) -> void:
	if _selected_card and is_instance_valid(_selected_card):
		_selected_card.add_theme_stylebox_override("panel", _style_card_normal.duplicate())
		_set_card_icon_active(_selected_card, false)
		_selected_card.scale = Vector2.ONE

	_selected_card = card
	_selected_config = config
	card.add_theme_stylebox_override("panel", _style_card_selected.duplicate())
	_set_card_icon_active(card, true)
	_update_detail_panel(animate)
	_update_play_button()

	if animate:
		_bounce_card(card)


func _bounce_card(card: PanelContainer) -> void:
	card.scale = Vector2.ONE
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2(1.03, 1.03), 0.1)
	tween.tween_property(card, "scale", Vector2.ONE, 0.18)


func _update_detail_panel(animate: bool) -> void:
	if _selected_config == null:
		_description.text = "No adventures available yet."
		_play_button.disabled = true
		return

	_description.text = (
		_selected_config.description
		if not _selected_config.description.is_empty()
		else "Adventure awaits!"
	)

	if not animate:
		_description.modulate = Color.WHITE
		return

	if _ui_tween and _ui_tween.is_valid():
		_ui_tween.kill()
	_description.modulate = Color(1, 1, 1, 0)
	_ui_tween = create_tween()
	_ui_tween.tween_property(_description, "modulate:a", 1.0, 0.22).set_ease(Tween.EASE_OUT)


func _update_play_button() -> void:
	_play_button.disabled = _selected_config == null


func _animate_title() -> void:
	var pulse := 0.92 + 0.08 * (0.5 + 0.5 * sin(_time * 1.8))
	_title.modulate = Color(pulse, pulse * 0.96, pulse * 0.78, 1.0)


func _pulse_selected_card() -> void:
	if _selected_card == null or not is_instance_valid(_selected_card):
		return
	var style := _selected_card.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return
	var pulse := 0.5 + 0.5 * sin(_time * 3.2)
	style.border_color = Color(1.0, 0.88, 0.35, 1.0).lerp(Color(1.0, 0.72, 0.2, 1.0), pulse * 0.4)
	style.bg_color = Color(0.22, 0.16, 0.32, 0.98).lerp(Color(0.26, 0.18, 0.36, 0.98), pulse * 0.25)


func _start_game(config: GameConfig) -> void:
	if config == null:
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.22)
	await tween.finished
	GameManager.start_game(config)


func _on_card_gui_input(event: InputEvent, config: GameConfig, card: PanelContainer) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			card.grab_focus()
			_select_card(config, card)


func _on_card_focused(config: GameConfig, card: PanelContainer) -> void:
	_select_card(config, card)


func _on_card_hovered(card: PanelContainer) -> void:
	if card == _selected_card:
		return
	card.add_theme_stylebox_override("panel", _style_card_hover.duplicate())


func _on_card_unhovered(card: PanelContainer) -> void:
	if card == _selected_card:
		return
	card.add_theme_stylebox_override("panel", _style_card_normal.duplicate())


func _on_play_pressed() -> void:
	if _selected_config:
		_start_game(_selected_config)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and _selected_config and not _play_button.disabled:
		_on_play_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _on_back_pressed() -> void:
	GameManager.quit_to_main_menu()
