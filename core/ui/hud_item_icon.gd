class_name HudItemIcon
extends Control

## Inventory slot icon — PNG when present, else procedural draw.

const ITEMS_PATH := "res://games/treasure-island/art/items/"

var icon_id: String = ""
var empty_label: String = ""
var _texture: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func configure(item_id: String) -> void:
	if item_id.is_empty():
		icon_id = ""
		_texture = null
	else:
		icon_id = ItemCatalog.get_icon_id(item_id)
		empty_label = ""
		_load_texture()
	queue_redraw()


func set_empty_label(text: String) -> void:
	empty_label = text
	queue_redraw()


func _load_texture() -> void:
	_texture = null
	if icon_id.is_empty():
		return
	var path := ITEMS_PATH.path_join("%s.png" % icon_id)
	if not ResourceLoader.exists(path):
		path = ITEMS_PATH.path_join("default.png")
	if ResourceLoader.exists(path):
		_texture = load(path) as Texture2D


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
		var color := Color(0.5, 0.45, 0.36, 1.0)
		var baseline_y := (size.y + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
		draw_string(
			font, Vector2(0.0, baseline_y), empty_label,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, color
		)
		return

	if _texture != null:
		var tw := float(_texture.get_width())
		var th := float(_texture.get_height())
		var scale := minf(size.x / tw, size.y / th) * 0.85
		var draw_size := Vector2(tw * scale, th * scale)
		var pos := (size - draw_size) * 0.5
		draw_texture_rect(_texture, Rect2(pos, draw_size), false)
		return

	var ps := minf(size.x, size.y) / float(ItemIconDraw.GRID)
	ps = clampf(ps, 1.0, 2.0)
	ItemIconDraw.draw_icon(self, icon_id, Rect2(Vector2.ZERO, size), ps, false)
