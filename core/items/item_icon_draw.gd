class_name ItemIconDraw
extends RefCounted

## Shared pixel-icon drawing for world (Node2D) and HUD (Control).

const GRID := 14


static func draw_icon(
	canvas: CanvasItem,
	icon_id: String,
	area: Rect2,
	pixel_size: float,
	with_shadow: bool = false
) -> void:
	var ps := pixel_size
	var content := Vector2(GRID * ps, GRID * ps)
	var origin := area.position + (area.size - content) * 0.5
	canvas.draw_set_transform(origin, 0.0, Vector2.ONE)

	if with_shadow:
		canvas.draw_circle(
			Vector2(content.x * 0.5, content.y * 0.82),
			ps * 1.2,
			Color(0, 0, 0, 0.18)
		)

	match icon_id:
		"snorkel":
			_draw_snorkel(canvas, ps)
		"coin":
			_draw_coin(canvas, ps)
		_:
			_draw_default(canvas, ps)

	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _px(canvas: CanvasItem, x: int, y: int, ps: float, color: Color) -> void:
	canvas.draw_rect(Rect2(x * ps, y * ps, ps, ps), color)


static func _draw_snorkel(canvas: CanvasItem, ps: float) -> void:
	var tube := Color(0.22, 0.58, 0.88, 1.0)
	var tube_hi := Color(0.42, 0.72, 0.95, 1.0)
	var mask := Color(0.18, 0.42, 0.72, 1.0)
	var strap := Color(0.82, 0.22, 0.18, 1.0)
	var mouth := Color(0.95, 0.35, 0.28, 1.0)
	for x in range(3, 11):
		_px(canvas, x, 2, ps, mask)
		_px(canvas, x, 3, ps, mask if x in range(4, 10) else tube_hi)
	_px(canvas, 4, 4, ps, tube_hi)
	_px(canvas, 9, 4, ps, tube_hi)
	for y in range(4, 11):
		for x in range(5, 9):
			_px(canvas, x, y, ps, tube_hi if x == 8 else tube)
	_px(canvas, 6, 11, ps, mouth)
	_px(canvas, 7, 11, ps, mouth)
	_px(canvas, 6, 12, ps, mouth)
	_px(canvas, 7, 12, ps, mouth)
	for x in range(3, 11):
		_px(canvas, x, 13, ps, strap)


static func _draw_coin(canvas: CanvasItem, ps: float) -> void:
	var gold := Color(1.0, 0.82, 0.18, 1.0)
	var shade := Color(0.78, 0.58, 0.08, 1.0)
	for x in range(4, 10):
		for y in range(4, 10):
			var edge := x == 4 or y == 4 or x == 9 or y == 9
			_px(canvas, x, y, ps, shade if edge else gold)


static func _draw_default(canvas: CanvasItem, ps: float) -> void:
	var box := Color(0.55, 0.48, 0.68, 1.0)
	for x in range(4, 10):
		for y in range(4, 10):
			_px(canvas, x, y, ps, box)
