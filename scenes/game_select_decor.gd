extends Control

const STAR_POSITIONS: Array[Vector2] = [
	Vector2(0.07, 0.05), Vector2(0.18, 0.11), Vector2(0.31, 0.04),
	Vector2(0.44, 0.09), Vector2(0.58, 0.06), Vector2(0.71, 0.12),
	Vector2(0.86, 0.05), Vector2(0.93, 0.14), Vector2(0.12, 0.16),
	Vector2(0.52, 0.15), Vector2(0.76, 0.18),
]

const FIREFLY_SEEDS: Array[Vector2] = [
	Vector2(0.14, 0.78), Vector2(0.38, 0.82), Vector2(0.62, 0.8), Vector2(0.84, 0.77),
]

var _time: float = 0.0
var _shooting_star_timer: float = 6.0
var _shooting_star_progress: float = 1.0
var _shooting_star_start := Vector2.ZERO
var _shooting_star_end := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shooting_star_timer = randf_range(4.0, 9.0)
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	_update_shooting_star(delta)
	queue_redraw()


func _update_shooting_star(delta: float) -> void:
	if _shooting_star_progress < 1.0:
		_shooting_star_progress = minf(_shooting_star_progress + delta * 0.85, 1.0)
		return

	_shooting_star_timer -= delta
	if _shooting_star_timer <= 0.0:
		_spawn_shooting_star()
		_shooting_star_timer = randf_range(7.0, 14.0)


func _spawn_shooting_star() -> void:
	var sz := size
	_shooting_star_start = Vector2(randf_range(sz.x * 0.1, sz.x * 0.55), randf_range(sz.y * 0.04, sz.y * 0.18))
	var length := randf_range(sz.x * 0.12, sz.x * 0.22)
	_shooting_star_end = _shooting_star_start + Vector2(length, length * randf_range(0.35, 0.55))
	_shooting_star_progress = 0.0


func _draw() -> void:
	var sz := size
	_draw_stars(sz)
	_draw_shooting_star()
	_draw_fireflies(sz)


func _draw_stars(sz: Vector2) -> void:
	for i in STAR_POSITIONS.size():
		var pos := Vector2(
			floorf(STAR_POSITIONS[i].x * sz.x),
			floorf(STAR_POSITIONS[i].y * sz.y)
		)
		var twinkle := 0.45 + 0.55 * (0.5 + 0.5 * sin(_time * 2.4 + float(i) * 1.9))
		var pixel_size := 4.0 if i % 3 == 0 else 2.0
		draw_rect(Rect2(pos, Vector2(pixel_size, pixel_size)), Color(1.0, 0.97, 0.82, twinkle))
		if i % 4 == 0 and twinkle > 0.92:
			var shine := Color(1.0, 1.0, 0.9, twinkle * 0.42)
			draw_rect(Rect2(pos - Vector2(6, 0), Vector2(14, 2)), shine)
			draw_rect(Rect2(pos - Vector2(0, 6), Vector2(2, 14)), shine)


func _draw_shooting_star() -> void:
	if _shooting_star_progress >= 1.0:
		return
	var head := _shooting_star_start.lerp(_shooting_star_end, _shooting_star_progress)
	var alpha := 1.0 - _shooting_star_progress
	var direction := (_shooting_star_end - _shooting_star_start).normalized()
	for step in 6:
		var point := head - direction * float(step * 6)
		point = Vector2(floorf(point.x), floorf(point.y))
		var pixel_size := 4.0 if step < 2 else 2.0
		var fade := alpha * (1.0 - float(step) / 7.0)
		draw_rect(
			Rect2(point, Vector2(pixel_size, pixel_size)),
			Color(1.0, 0.98, 0.86, fade)
		)


func _draw_fireflies(sz: Vector2) -> void:
	for i in FIREFLY_SEEDS.size():
		var seed := FIREFLY_SEEDS[i]
		var pos := Vector2(
			seed.x * sz.x + sin(_time * 0.7 + float(i) * 2.1) * 28.0,
			seed.y * sz.y + cos(_time * 0.9 + float(i) * 1.6) * 16.0
		)
		pos = Vector2(floorf(pos.x), floorf(pos.y))
		var glow := 0.25 + 0.75 * (0.5 + 0.5 * sin(_time * 3.0 + float(i) * 2.4))
		draw_rect(Rect2(pos - Vector2(2, 2), Vector2(6, 6)), Color(1.0, 0.82, 0.3, glow * 0.22))
		draw_rect(Rect2(pos, Vector2(2, 2)), Color(1.0, 0.98, 0.75, glow))
