class_name LoadingStrip
extends Control

## Chunky tape-loading indicator for the mandatory disclaimer pause.

const BLOCK_COUNT := 16

var _progress := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_progress(value: float) -> void:
	var next := clampf(value, 0.0, 1.0)
	if is_equal_approx(next, _progress):
		return
	_progress = next
	queue_redraw()


func get_progress() -> float:
	return _progress


func _draw() -> void:
	var outer := Rect2(Vector2.ZERO, size)
	draw_rect(outer, Color(0.06, 0.05, 0.12, 0.96))
	draw_rect(outer.grow(-1.0), Color(0.72, 0.56, 0.25, 0.92), false, 1.0)

	var inner := outer.grow(-4.0)
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		return
	var gap := 2.0
	var block_width := floorf((inner.size.x - gap * float(BLOCK_COUNT - 1)) / float(BLOCK_COUNT))
	if block_width < 1.0:
		return
	var filled := floori(_progress * float(BLOCK_COUNT) + 0.001)
	for index in BLOCK_COUNT:
		var x := inner.position.x + float(index) * (block_width + gap)
		var rect := Rect2(Vector2(x, inner.position.y), Vector2(block_width, inner.size.y))
		var color := Color(0.16, 0.13, 0.22, 1.0)
		if index < filled:
			color = (
				Color(1.0, 0.86, 0.35, 1.0)
				if index % 2 == 0
				else Color(0.94, 0.31, 0.23, 1.0)
			)
		draw_rect(rect, color)
