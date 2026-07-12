class_name BeachBackdrop
extends Node2D

## Treasure Island beach sky/sea/sand backdrop (512×384).

var _time: float = 0.0


func _ready() -> void:
	set_process(true)
	z_index = -10


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var w := 512.0
	var h := 384.0
	var sand_top := h - 48.0

	# Sky gradient bands
	draw_rect(Rect2(0, 0, w, sand_top * 0.55), Color(0.38, 0.62, 0.92, 1.0))
	draw_rect(Rect2(0, sand_top * 0.55, w, sand_top * 0.45), Color(0.48, 0.72, 0.96, 1.0))

	# Distant sea
	draw_rect(Rect2(0, sand_top - 36.0, w, 36.0), Color(0.2, 0.48, 0.72, 1.0))
	for i in 4:
		var y := sand_top - 30.0 + float(i) * 6.0
		var offset := sin(_time * 1.4 + float(i) * 0.9) * 8.0
		draw_line(Vector2(0, y), Vector2(w * 0.4 + offset, y - 1.0), Color(0.32, 0.6, 0.86, 0.45), 2.0)
		draw_line(Vector2(w * 0.4 + offset, y - 1.0), Vector2(w, y), Color(0.32, 0.6, 0.86, 0.45), 2.0)

	# Sand
	draw_rect(Rect2(0, sand_top, w, h - sand_top), Color(0.86, 0.72, 0.42, 1.0))
	draw_rect(Rect2(0, sand_top, w, 6.0), Color(0.72, 0.58, 0.32, 0.55))

	# Clouds
	_draw_cloud(Vector2(90, 42), 0.0)
	_draw_cloud(Vector2(280, 58), 1.4)
	_draw_cloud(Vector2(420, 36), 2.8)


func _draw_cloud(center: Vector2, phase: float) -> void:
	var drift := sin(_time * 0.35 + phase) * 6.0
	center.x += drift
	var cloud := Color(1.0, 1.0, 1.0, 0.22)
	draw_circle(center, 14.0, cloud)
	draw_circle(center + Vector2(-16, 4), 10.0, cloud)
	draw_circle(center + Vector2(16, 5), 11.0, cloud)
