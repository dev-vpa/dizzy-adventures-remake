class_name ItemSprite
extends Node2D

## Procedural pixel icon for world pickups and HUD slots.

const GRID := 12

var icon_id: String = "default"
var _pixel_size: float = 1.5
var _time: float = 0.0
var bob_enabled: bool = true


func _ready() -> void:
	set_process(true)


func configure(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	queue_redraw()


func _process(delta: float) -> void:
	if bob_enabled:
		_time += delta
		queue_redraw()


func _draw() -> void:
	var bob := sin(_time * 3.0) * 1.2 if bob_enabled else 0.0
	var origin := Vector2(-GRID * _pixel_size * 0.5, -GRID * _pixel_size * 0.5 + bob)
	draw_set_transform(origin, 0.0, Vector2.ONE)

	match icon_id:
		"snorkel":
			_draw_snorkel()
		"coin":
			_draw_coin()
		_:
			_draw_default()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _px(x: int, y: int, color: Color) -> void:
	draw_rect(Rect2(x * _pixel_size, y * _pixel_size, _pixel_size, _pixel_size), color)


func _draw_snorkel() -> void:
	var tube := Color(0.22, 0.58, 0.88, 1.0)
	var mask := Color(0.18, 0.42, 0.72, 1.0)
	var strap := Color(0.82, 0.22, 0.18, 1.0)
	for y in range(3, 10):
		_px(5, y, tube)
		_px(6, y, tube)
	for x in range(3, 9):
		_px(x, 2, mask)
	_px(4, 3, Color(0.35, 0.72, 0.92, 1.0))
	_px(7, 3, Color(0.35, 0.72, 0.92, 1.0))
	for x in range(2, 8):
		_px(x, 9, strap)


func _draw_coin() -> void:
	var gold := Color(1.0, 0.82, 0.18, 1.0)
	var shade := Color(0.78, 0.58, 0.08, 1.0)
	for x in range(3, 9):
		for y in range(3, 9):
			var edge := x == 3 or y == 3 or x == 8 or y == 8
			_px(x, y, shade if edge else gold)


func _draw_default() -> void:
	var box := Color(0.55, 0.48, 0.68, 1.0)
	for x in range(3, 9):
		for y in range(3, 9):
			_px(x, y, box)
