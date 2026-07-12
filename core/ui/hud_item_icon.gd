class_name HudItemIcon
extends Control

## Inventory slot icon — Control-based, stays inside slot bounds.

var icon_id: String = ""
var empty_label: String = ""


func configure(item_id: String) -> void:
	if item_id.is_empty():
		icon_id = ""
	else:
		icon_id = ItemCatalog.get_icon_id(item_id)
	queue_redraw()


func set_empty_label(text: String) -> void:
	empty_label = text
	queue_redraw()


func _draw() -> void:
	if icon_id.is_empty():
		if not empty_label.is_empty():
			var font := ThemeDB.fallback_font
			var font_size := 10
			var text_size := font.get_string_size(empty_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			var pos := (size - text_size) * 0.5
			draw_string(font, pos, empty_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.42, 0.38, 0.32, 1.0))
		return

	var ps := minf(size.x, size.y) / float(ItemIconDraw.GRID)
	ps = clampf(ps, 1.0, 2.2)
	ItemIconDraw.draw_icon(self, icon_id, Rect2(Vector2.ZERO, size), ps, false)
