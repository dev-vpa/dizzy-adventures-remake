class_name DizzySprite
extends Node2D

## Pixel Dizzy — PNG frames: idle / walk / jump / roll; snorkel overlay when held.

const FRAMES_PATH := "res://shared/sprites/dizzy/"

var facing: int = 1
var _anim_phase: float = 0.0
var _idle: Texture2D
var _walk_a: Texture2D
var _walk_b: Texture2D
var _jump: Texture2D
var _roll_a: Texture2D
var _roll_b: Texture2D


func _ready() -> void:
	Inventory.inventory_changed.connect(_on_inventory_changed)
	_idle = _load_frame("idle")
	_walk_a = _load_frame("walk_a")
	_walk_b = _load_frame("walk_b")
	_jump = _load_frame("jump")
	_roll_a = _load_frame("roll_a")
	_roll_b = _load_frame("roll_b")
	queue_redraw()


func _load_frame(name: String) -> Texture2D:
	var path := FRAMES_PATH.path_join("%s.png" % name)
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _on_inventory_changed() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	if _is_walking() or _is_airborne():
		_anim_phase += delta * 10.0
	queue_redraw()


func set_facing(direction: int) -> void:
	if direction == 0:
		return
	facing = 1 if direction > 0 else -1
	queue_redraw()


func _body() -> CharacterBody2D:
	if is_instance_valid(get_parent()) and get_parent() is CharacterBody2D:
		return get_parent() as CharacterBody2D
	return null


func _is_walking() -> bool:
	var body := _body()
	return body != null and absf(body.velocity.x) > 1.0 and body.is_on_floor()


func _is_airborne() -> bool:
	var body := _body()
	return body != null and not body.is_on_floor()


func _current_texture() -> Texture2D:
	if _is_airborne():
		var body := _body()
		if body != null and body.velocity.y < -20.0 and _jump != null:
			return _jump
		if _roll_a != null and _roll_b != null:
			return _roll_a if int(_anim_phase) % 2 == 0 else _roll_b
		if _jump != null:
			return _jump
	if _is_walking() and _walk_a and _walk_b:
		return _walk_a if int(_anim_phase) % 2 == 0 else _walk_b
	return _idle


func _draw() -> void:
	var tex := _current_texture()
	if tex == null:
		return
	var size := tex.get_size()
	var pos := Vector2(-size.x * 0.5, -size.y + 4.0)
	if facing < 0:
		draw_set_transform(Vector2(0, 0), 0.0, Vector2(-1, 1))
	draw_texture(tex, pos)
	if Inventory.has_item("snorkel"):
		_draw_snorkel_mask()
	if facing < 0:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_snorkel_mask() -> void:
	var tex := _current_texture()
	if tex == null:
		return
	# Keep the overlay on the 22px authored source grid at any export scale.
	# It is authored facing right and mirrors with the body.
	var p := float(tex.get_width()) / 22.0
	var frame_top := -float(tex.get_height()) + 4.0
	var mask_y := frame_top + 8.0 * p
	var mask_left := -5.0 * p
	var rim := Color(0.08, 0.16, 0.28, 1.0)
	var frame := Color(0.16, 0.43, 0.72, 1.0)
	var lens := Color(0.32, 0.72, 0.86, 0.82)
	var shine := Color(0.78, 0.94, 0.95, 0.95)
	var tube := Color(0.88, 0.25, 0.20, 1.0)
	var tube_hi := Color(1.0, 0.48, 0.28, 1.0)

	var tube_x := 5.0 * p
	draw_rect(Rect2(tube_x, mask_y - 7.0 * p, 3.0 * p, 10.0 * p), rim)
	draw_rect(Rect2(tube_x + p, mask_y - 6.0 * p, p, 8.0 * p), tube)
	draw_rect(Rect2(tube_x + p, mask_y - 6.0 * p, 2.0 * p, p), tube_hi)
	var mouth_x := 4.0 * p
	draw_rect(Rect2(mouth_x, mask_y + 2.0 * p, 4.0 * p, 2.0 * p), rim)
	draw_rect(Rect2(mouth_x + p, mask_y + 2.0 * p, 3.0 * p, p), tube)

	draw_rect(Rect2(mask_left - p, mask_y - p, 12.0 * p, 5.0 * p), rim)
	draw_rect(Rect2(mask_left, mask_y, 10.0 * p, 3.0 * p), frame)
	draw_rect(Rect2(mask_left + p, mask_y + p, 3.0 * p, p), lens)
	draw_rect(Rect2(mask_left + 6.0 * p, mask_y + p, 3.0 * p, p), lens)
	draw_rect(Rect2(mask_left + 4.0 * p, mask_y + p, 2.0 * p, p), rim)
	draw_rect(Rect2(mask_left + p, mask_y, 2.0 * p, p), shine)
