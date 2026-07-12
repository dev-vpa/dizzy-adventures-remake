extends Node2D

## Underwater backdrop for TI shallow water screens.

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
	draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.22, 0.42, 1.0))
	draw_rect(Rect2(0, 0, w, 48.0), Color(0.1, 0.32, 0.52, 0.55))
	for i in 6:
		var y := 60.0 + float(i) * 48.0
		var offset := sin(_time * 1.2 + float(i) * 0.7) * 12.0
		draw_line(Vector2(0, y), Vector2(w * 0.5 + offset, y), Color(0.18, 0.42, 0.62, 0.25), 2.0)
		draw_line(Vector2(w * 0.5 + offset, y), Vector2(w, y + 2.0), Color(0.18, 0.42, 0.62, 0.25), 2.0)
	draw_rect(Rect2(0, h - 32.0, w, 32.0), Color(0.72, 0.58, 0.32, 1.0))
