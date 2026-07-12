class_name HudItemIcon
extends Control

## Inventory slot icon — draws inside fixed slot bounds.

var icon_id: String = ""
var empty_label: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func configure(item_id: String) -> void:
	if item_id.is_empty():
		icon_id = ""
	else:
		icon_id = ItemCatalog.get_icon_id(item_id)
	queue_redraw()


func set_empty_label(text: String) -> void:
	empty_label = text
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x < 2.0 or size.y < 2.0:
		return

	if icon_id.is_empty():
		if empty_label.is_empty():
			return
		var font := ThemeDB.fallback_font
		var font_size := 11
		var text_size := font.get_string_size(empty_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var pos := (size - text_size) * 0.5 + Vector2(0, 1)
		draw_string(
			font, pos, empty_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,
			Color(0.5, 0.45, 0.36, 1.0)
		)
		return

	var ps := minf(size.x, size.y) / float(ItemIconDraw.GRID)
	ps = clampf(ps, 1.0, 2.0)
	ItemIconDraw.draw_icon(self, icon_id, Rect2(Vector2.ZERO, size), ps, false)
