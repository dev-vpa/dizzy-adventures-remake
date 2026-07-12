extends Area2D

## One-way screen transition (e.g. shop door). Player must approach from the west (left).

@export var target_screen_id: String = ""
@export var spawn_position: Vector2 = Vector2(140, 320)
@export var block_edge_on_arrival: String = "left"

var _cooldown := 0.0


func _ready() -> void:
	add_to_group("screen_door")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta


func _on_body_entered(body: Node2D) -> void:
	if _cooldown > 0.0:
		return
	if not body.is_in_group("player"):
		return
	if target_screen_id.is_empty():
		return
	if body.global_position.x >= global_position.x - 12.0:
		return

	var world := get_tree().get_first_node_in_group("game_world")
	if world and world.has_method("request_door_transition"):
		world.call("request_door_transition", body, target_screen_id, spawn_position, block_edge_on_arrival)
		_cooldown = 0.8
