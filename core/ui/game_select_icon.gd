class_name GameSelectIcon
extends Control

## Retro pixel-style adventure thumbnail. Uses GameConfig.icon when set, else draws by game id.

const GRID_SIZE := 24
const FRAME_INSET := 2.0

@export var game_id: String = ""
@export var icon_texture: Texture2D

var active: bool = false

var _time: float = 0.0
var _pixel_size: float = 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	_recalc_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalc_layout()


func configure(config: GameConfig) -> void:
	game_id = config.id
	icon_texture = config.icon
	queue_redraw()


func set_active(value: bool) -> void:
	active = value
	queue_redraw()


func _recalc_layout() -> void:
	var inner := minf(size.x, size.y) - FRAME_INSET * 2.0
	_pixel_size = floorf(inner / float(GRID_SIZE))
	if _pixel_size < 1.0:
		_pixel_size = 1.0


func _process(delta: float) -> void:
	_time += delta
	if active:
		queue_redraw()


func _draw() -> void:
	var bob := sin(_time * 3.2) * 1.6 if active else 0.0
	var glow := 0.08 + 0.06 * sin(_time * 4.0) if active else 0.0
	var frame_rect := Rect2(Vector2.ZERO, size)
	draw_rect(frame_rect, Color(0.04, 0.03, 0.08, 0.82))
	draw_rect(frame_rect.grow(-1.0), Color(0.28, 0.22, 0.16, 0.95), false, 1.0)
	if active:
		draw_rect(frame_rect.grow(-3.0), Color(1.0, 0.86, 0.35, glow), false, 1.0)

	var art_origin := Vector2(
		(size.x - _pixel_size * GRID_SIZE) * 0.5,
		(size.y - _pixel_size * GRID_SIZE) * 0.5 + bob
	)
	draw_set_transform(art_origin, 0.0, Vector2.ONE)

	if icon_texture:
		var tex_rect := Rect2(Vector2.ZERO, Vector2(_pixel_size * GRID_SIZE, _pixel_size * GRID_SIZE))
		draw_texture_rect(icon_texture, tex_rect, false)
	else:
		match game_id:
			"treasure-island":
				_draw_treasure_island()
			_:
				_draw_default()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _px(x: int, y: int, color: Color) -> void:
	draw_rect(
		Rect2(x * _pixel_size, y * _pixel_size, _pixel_size, _pixel_size),
		color
	)


func _draw_treasure_island() -> void:
	var sea := Color(0.18, 0.42, 0.72, 1.0)
	var sea_light := Color(0.28, 0.55, 0.82, 1.0)
	var sand := Color(0.78, 0.62, 0.32, 1.0)
	var sand_dark := Color(0.62, 0.48, 0.24, 1.0)
	var palm := Color(0.18, 0.52, 0.22, 1.0)
	var trunk := Color(0.45, 0.3, 0.14, 1.0)
	var coin := Color(1.0, 0.82, 0.18, 1.0)
	var dizzy := Color(0.88, 0.18, 0.14, 1.0)
	var dizzy_hi := Color(1.0, 0.55, 0.48, 1.0)

	for x in GRID_SIZE:
		for y in range(14, GRID_SIZE):
			_px(x, y, sea if (x + y) % 3 else sea_light)

	for x in range(4, 20):
		for y in range(10, 14):
			_px(x, y, sand_dark if y == 13 else sand)

	_px(10, 9, trunk)
	_px(10, 8, trunk)
	_px(10, 7, trunk)
	_px(9, 6, palm)
	_px(10, 6, palm)
	_px(11, 6, palm)
	_px(8, 5, palm)
	_px(12, 5, palm)
	_px(13, 7, coin)
	_px(14, 7, coin)
	_px(13, 8, Color(0.82, 0.62, 0.08, 1.0))

	_px(6, 11, dizzy)
	_px(7, 11, dizzy)
	_px(6, 10, dizzy_hi)
	_px(7, 10, dizzy_hi)
	_px(6, 9, dizzy)


func _draw_default() -> void:
	var box := Color(0.35, 0.28, 0.48, 1.0)
	var mark := Color(1.0, 0.88, 0.42, 1.0)
	for x in range(7, 17):
		for y in range(7, 17):
			_px(x, y, box)
	for x in range(10, 14):
		_px(x, 11, mark)
	for y in range(8, 14):
		_px(11, y, mark)
