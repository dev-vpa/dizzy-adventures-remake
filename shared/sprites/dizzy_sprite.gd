class_name DizzySprite
extends Node2D

## Procedural pixel-art Dizzy placeholder (shared across games).

const GRID_W := 16
const GRID_H := 20
const PIXEL_SIZE := 3.0

var facing: int = 1
var _walk_phase: float = 0.0


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	if _is_walking():
		_walk_phase += delta * 10.0
	queue_redraw()


func set_facing(direction: int) -> void:
	if direction == 0:
		return
	facing = 1 if direction > 0 else -1
	queue_redraw()


func _is_walking() -> bool:
	return is_instance_valid(get_parent()) and get_parent() is CharacterBody2D and absf((get_parent() as CharacterBody2D).velocity.x) > 1.0 and (get_parent() as CharacterBody2D).is_on_floor()


func _draw() -> void:
	var body := Color(0.88, 0.16, 0.12, 1.0)
	var body_hi := Color(1.0, 0.42, 0.34, 1.0)
	var body_sh := Color(0.62, 0.1, 0.08, 1.0)
	var glove := Color(0.98, 0.94, 0.82, 1.0)
	var shoe := Color(0.92, 0.78, 0.18, 1.0)
	var eye := Color(0.08, 0.06, 0.1, 1.0)
	var cheek := Color(0.96, 0.55, 0.42, 1.0)

	var origin := Vector2(-GRID_W * PIXEL_SIZE * 0.5, -GRID_H * PIXEL_SIZE)
	draw_set_transform(origin, 0.0, Vector2.ONE)

	var bob := int(sin(_walk_phase) * 0.5) if _is_walking() else 0

	for x in GRID_W:
		for y in GRID_H:
			var color := _body_pixel(x, y, body, body_hi, body_sh, glove, shoe, eye, cheek, bob)
			if color.a > 0.0:
				var draw_x := x if facing > 0 else GRID_W - 1 - x
				_px(draw_x, y + bob, color)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _body_pixel(
	x: int, y: int,
	body: Color, body_hi: Color, body_sh: Color,
	glove: Color, shoe: Color, eye: Color, cheek: Color,
	bob: int
) -> Color:
	var _y := y - bob
	# Egg body (wider)
	if x in range(4, 12) and _y in range(5, 15):
		if x <= 6:
			return body_sh
		if x >= 9:
			return body_hi
		return body
	if x in range(3, 13) and _y in range(3, 6):
		return body_hi if x > 8 else body
	if x in range(3, 13) and _y in range(15, 17):
		return body_sh
	# Face
	if x in range(6, 10) and _y == 8:
		return eye
	if x in range(5, 8) and _y == 10:
		return cheek
	# Gloves
	if x in range(2, 5) and _y in range(11, 13):
		return glove
	if x in range(11, 14) and _y in range(11, 13):
		return glove
	# Shoes
	if x in range(5, 8) and _y in range(17, 20):
		return shoe
	if x in range(9, 12) and _y in range(17, 20):
		return shoe
	return Color.TRANSPARENT


func _px(x: int, y: int, color: Color) -> void:
	draw_rect(
		Rect2(x * PIXEL_SIZE, y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE),
		color
	)
