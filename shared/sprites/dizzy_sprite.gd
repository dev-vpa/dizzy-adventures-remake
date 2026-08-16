class_name DizzySprite
extends Node2D

## Pixel Dizzy — PNG frames: idle / walk / jump / roll; snorkel overlay when held.

const FRAMES_PATH := "res://shared/sprites/dizzy/"
const ROLL_DELAY := 0.08
const ROLL_TURNS_PER_SECOND := 1.75
const ROLL_FRAME_RATE := 8.0

var facing: int = 1
var _anim_phase: float = 0.0
var _airborne_time: float = 0.0
var _was_airborne := false
var _roll_direction := 1
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
	var airborne := _is_airborne()
	if airborne:
		if not _was_airborne:
			_airborne_time = 0.0
			_roll_direction = facing
		_airborne_time += delta
	else:
		_airborne_time = 0.0
	_was_airborne = airborne
	if _is_walking():
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


func _is_rolling() -> bool:
	return _is_airborne() and _airborne_time >= ROLL_DELAY


func _roll_angle() -> float:
	if not _is_rolling():
		return 0.0
	var turns := (_airborne_time - ROLL_DELAY) * ROLL_TURNS_PER_SECOND
	return fmod(turns * TAU, TAU) * float(_roll_direction)


func _current_texture() -> Texture2D:
	if _is_airborne():
		if not _is_rolling() and _jump != null:
			return _jump
		if _roll_a != null and _roll_b != null:
			var frame := int((_airborne_time - ROLL_DELAY) * ROLL_FRAME_RATE)
			return _roll_a if frame % 2 == 0 else _roll_b
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
	if _is_rolling():
		# Rotate around the visible body's centre, never around Dizzy's feet.
		var pivot := pos + size * 0.5
		var centered_pos := -size * 0.5
		draw_set_transform(pivot, _roll_angle(), Vector2(float(facing), 1.0))
		draw_texture(tex, centered_pos)
		if Inventory.has_item("snorkel"):
			_draw_snorkel_mask(tex, centered_pos.y)
	else:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(float(facing), 1.0))
		draw_texture(tex, pos)
		if Inventory.has_item("snorkel"):
			_draw_snorkel_mask(tex, pos.y)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_snorkel_mask(tex: Texture2D, frame_top: float) -> void:
	# Overlay coords use the classic 22-unit face grid; p maps them onto the
	# exported texture (88px wide from a 44×56 authored frame ×2).
	var p := float(tex.get_width()) / 22.0
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
