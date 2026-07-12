extends Area2D

## One-way screen transition (e.g. shop door). Press action while at the door.

@export var target_screen_id: String = ""
@export var spawn_position: Vector2 = Vector2(140, 320)
@export var block_edge_on_arrival: String = "left"

var _cooldown := 0.0
var _player_near := false
var _hint: Label


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	add_to_group("screen_door")
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_hint = get_node_or_null("HintLabel") as Label


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta
	_update_hint()


func _update_hint() -> void:
	if _hint == null:
		return
	_hint.text = PlatformUI.hint_text("E — Enter", "Enter")
	_hint.visible = _player_near


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = false


func try_interact() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return _try_enter(body)
	return false


func _try_enter(body: Node2D) -> bool:
	if _cooldown > 0.0:
		return false
	if not body.is_in_group("player"):
		return false
	if target_screen_id.is_empty():
		return false

	var world := get_tree().get_first_node_in_group("game_world")
	if world and world.has_method("request_door_transition"):
		world.call("request_door_transition", body, target_screen_id, spawn_position, block_edge_on_arrival)
		_cooldown = 0.8
		return true
	return false
