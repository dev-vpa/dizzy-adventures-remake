class_name ItemSprite
extends Node2D

## Procedural pixel icon for world pickups and HUD slots.

const GRID := 14

var icon_id: String = "default"
var _pixel_size: float = 1.5
var _time: float = 0.0
var bob_enabled: bool = true


func _ready() -> void:
	set_process(true)


func configure(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	_pixel_size = 1.5
	queue_redraw()


func configure_for_world(item_id: String) -> void:
	icon_id = ItemCatalog.get_icon_id(item_id)
	_pixel_size = 2.5
	bob_enabled = true
	queue_redraw()


func _process(delta: float) -> void:
	if bob_enabled:
		_time += delta
		queue_redraw()


func _draw() -> void:
	var bob := sin(_time * 3.0) * 1.5 if bob_enabled else 0.0
	var origin := Vector2(-GRID * _pixel_size * 0.5, -GRID * _pixel_size * 0.75 + bob)
	draw_set_transform(origin, 0.0, Vector2.ONE)

	# Soft shadow on ground
	draw_circle(Vector2(GRID * _pixel_size * 0.5, GRID * _pixel_size * 0.78 + bob), 5.0 * _pixel_size * 0.22, Color(0, 0, 0, 0.18))

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
	var tube_hi := Color(0.42, 0.72, 0.95, 1.0)
	var mask := Color(0.18, 0.42, 0.72, 1.0)
	var strap := Color(0.82, 0.22, 0.18, 1.0)
	var mouth := Color(0.95, 0.35, 0.28, 1.0)
	# Mask (top)
	for x in range(3, 11):
		_px(x, 2, mask)
		_px(x, 3, mask if x in range(4, 10) else tube_hi)
	_px(4, 4, tube_hi)
	_px(9, 4, tube_hi)
	# Tube (wide)
	for y in range(4, 11):
		for x in range(5, 9):
			_px(x, y, tube_hi if x == 8 else tube)
	# Mouthpiece
	_px(6, 11, mouth)
	_px(7, 11, mouth)
	_px(6, 12, mouth)
	_px(7, 12, mouth)
	# Strap
	for x in range(3, 11):
		_px(x, 13, strap)


func _draw_coin() -> void:
	var gold := Color(1.0, 0.82, 0.18, 1.0)
	var shade := Color(0.78, 0.58, 0.08, 1.0)
	for x in range(4, 10):
		for y in range(4, 10):
			var edge := x == 4 or y == 4 or x == 9 or y == 9
			_px(x, y, shade if edge else gold)


func _draw_default() -> void:
	var box := Color(0.55, 0.48, 0.68, 1.0)
	for x in range(4, 10):
		for y in range(4, 10):
			_px(x, y, box)
