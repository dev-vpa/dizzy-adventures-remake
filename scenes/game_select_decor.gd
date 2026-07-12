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
	_draw_moon(sz)
	_draw_stars(sz)
	_draw_shooting_star()
	_draw_horizon_glow(sz)
	_draw_fireflies(sz)
	_draw_palm_silhouettes(sz)
	_draw_waves(sz)


func _draw_moon(sz: Vector2) -> void:
	var moon_center := Vector2(sz.x * 0.84, sz.y * 0.09)
	var glow := 0.28 + 0.1 * sin(_time * 1.4)
	draw_circle(moon_center, 22.0, Color(1.0, 0.94, 0.72, glow * 0.35))
	draw_circle(moon_center, 16.0, Color(1.0, 0.94, 0.72, 0.38))
	draw_circle(moon_center + Vector2(5.0, -2.0), 13.0, Color(0.2, 0.28, 0.48, 0.55))


func _draw_stars(sz: Vector2) -> void:
	for i in STAR_POSITIONS.size():
		var pos := Vector2(STAR_POSITIONS[i].x * sz.x, STAR_POSITIONS[i].y * sz.y)
		var twinkle := 0.45 + 0.55 * (0.5 + 0.5 * sin(_time * 2.4 + float(i) * 1.9))
		var radius := 1.2 if i % 3 == 0 else 0.9
		draw_circle(pos, radius, Color(1.0, 0.97, 0.82, twinkle))
		if i % 4 == 0 and twinkle > 0.92:
			draw_line(pos - Vector2(3, 0), pos + Vector2(3, 0), Color(1, 1, 0.9, twinkle * 0.35), 1.0)
			draw_line(pos - Vector2(0, 3), pos + Vector2(0, 3), Color(1, 1, 0.9, twinkle * 0.35), 1.0)


func _draw_shooting_star() -> void:
	if _shooting_star_progress >= 1.0:
		return
	var head := _shooting_star_start.lerp(_shooting_star_end, _shooting_star_progress)
	var tail := _shooting_star_start.lerp(_shooting_star_end, maxf(_shooting_star_progress - 0.18, 0.0))
	var alpha := 1.0 - _shooting_star_progress
	draw_line(tail, head, Color(1.0, 0.98, 0.86, alpha * 0.75), 2.0)
	draw_circle(head, 1.6, Color(1.0, 1.0, 0.92, alpha))


func _draw_horizon_glow(sz: Vector2) -> void:
	var horizon_y := sz.y - 56.0
	var pulse := 0.1 + 0.04 * sin(_time * 0.9)
	draw_rect(Rect2(0.0, horizon_y - 22.0, sz.x, 22.0), Color(0.95, 0.55, 0.22, pulse))
	draw_rect(Rect2(0.0, horizon_y - 8.0, sz.x, 8.0), Color(0.72, 0.38, 0.18, pulse * 0.65))


func _draw_fireflies(sz: Vector2) -> void:
	for i in FIREFLY_SEEDS.size():
		var seed := FIREFLY_SEEDS[i]
		var pos := Vector2(
			seed.x * sz.x + sin(_time * 0.7 + float(i) * 2.1) * 14.0,
			seed.y * sz.y + cos(_time * 0.9 + float(i) * 1.6) * 8.0
		)
		var glow := 0.25 + 0.75 * (0.5 + 0.5 * sin(_time * 3.0 + float(i) * 2.4))
		draw_circle(pos, 2.2, Color(1.0, 0.92, 0.45, glow * 0.55))
		draw_circle(pos, 1.0, Color(1.0, 0.98, 0.75, glow))


func _draw_palm_silhouettes(sz: Vector2) -> void:
	_draw_palm(sz, Vector2(sz.x * 0.06, sz.y - 56.0), 0.9, false, 0.0)
	_draw_palm(sz, Vector2(sz.x * 0.92, sz.y - 56.0), 1.1, true, 1.7)


func _draw_palm(_sz: Vector2, base: Vector2, scale: float, flip: bool, phase: float) -> void:
	var trunk_color := Color(0.08, 0.06, 0.12, 0.55)
	var leaf_color := Color(0.06, 0.14, 0.1, 0.5)
	var dir := -1.0 if flip else 1.0
	var sway := sin(_time * 1.1 + phase) * 0.06
	var trunk_w := 6.0 * scale
	var trunk_h := 34.0 * scale
	draw_rect(Rect2(base.x - trunk_w * 0.5, base.y - trunk_h, trunk_w, trunk_h), trunk_color)
	for i in 4:
		var angle := (-0.35 + float(i) * 0.22 + sway) * dir
		var length := (22.0 + float(i) * 3.0) * scale
		var origin := base + Vector2(0.0, -trunk_h * 0.65)
		var end := origin + Vector2(cos(angle), sin(angle)) * length
		draw_line(origin, end, leaf_color, 3.0 * scale)


func _draw_waves(sz: Vector2) -> void:
	var sand_top := sz.y - 56.0
	var wave_color := Color(0.35, 0.55, 0.72, 0.35)
	var wave_hi := Color(0.48, 0.68, 0.86, 0.28)
	for i in 4:
		var y := sand_top - 4.0 - float(i) * 5.0
		var offset := sin(_time * 1.6 + float(i) * 1.2) * 7.0
		var crest_x := sz.x * 0.35 + offset
		draw_line(Vector2(0.0, y), Vector2(crest_x, y - 2.0), wave_color, 2.0)
		draw_line(Vector2(crest_x, y - 2.0), Vector2(sz.x, y), wave_color, 2.0)
		if i == 0:
			draw_line(Vector2(crest_x - 4.0, y - 3.0), Vector2(crest_x + 4.0, y - 1.0), wave_hi, 1.0)
