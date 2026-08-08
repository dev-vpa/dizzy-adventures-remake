extends Area2D

## Instant-death hazard — contact kills player (1 life games).

@export var hazard_label: String = "Trap"
@export var zone_size: Vector2 = Vector2(64, 32)
@export var zone_center: Vector2 = Vector2(256, 340)
## When this WorldState flag is true, the hazard is disabled (e.g. after bridge cut).
@export var clear_flag: String = ""

var _players_inside: Array[Node] = []


func _ready() -> void:
	add_to_group("hazard_zone")
	_apply_zone_bounds()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not clear_flag.is_empty():
		if not WorldState.flag_changed.is_connected(_on_flag_changed):
			WorldState.flag_changed.connect(_on_flag_changed)
		_apply_clear_state()


func _exit_tree() -> void:
	if WorldState.flag_changed.is_connected(_on_flag_changed):
		WorldState.flag_changed.disconnect(_on_flag_changed)


func _on_flag_changed(flag_id: String, _value: bool) -> void:
	if flag_id == clear_flag:
		_apply_clear_state()


func _apply_clear_state() -> void:
	var cleared := not clear_flag.is_empty() and WorldState.get_flag(clear_flag)
	monitoring = not cleared
	monitorable = false
	visible = not cleared
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = cleared
	if has_node("Visual"):
		$Visual.visible = not cleared
	if cleared:
		_players_inside.clear()


func _apply_zone_bounds() -> void:
	var collision: CollisionShape2D = $CollisionShape2D
	var shape := collision.shape as RectangleShape2D
	if shape:
		# Duplicate so per-instance size edits do not share one resource.
		shape = shape.duplicate()
		shape.size = zone_size
		collision.shape = shape
	collision.position = zone_center
	if has_node("Visual"):
		var visual: ColorRect = $Visual
		visual.z_index = 10
		visual.offset_left = zone_center.x - zone_size.x * 0.5
		visual.offset_top = zone_center.y - zone_size.y * 0.5
		visual.offset_right = zone_center.x + zone_size.x * 0.5
		visual.offset_bottom = zone_center.y + zone_size.y * 0.5


func _physics_process(_delta: float) -> void:
	if not monitoring:
		return
	for body in _players_inside.duplicate():
		if is_instance_valid(body):
			_kill_player(body)
		else:
			_players_inside.erase(body)


func _on_body_entered(body: Node2D) -> void:
	if not monitoring:
		return
	if body.is_in_group("player") and body not in _players_inside:
		_players_inside.append(body)
		_kill_player(body)


func _on_body_exited(body: Node2D) -> void:
	_players_inside.erase(body)


func _kill_player(body: Node) -> void:
	if not is_instance_valid(body) or not body.is_inside_tree():
		return
	if body.has_method("die_from_hazard"):
		body.call("die_from_hazard")
