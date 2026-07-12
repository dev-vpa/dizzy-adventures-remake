extends Area2D

## Water hazard — drowns player without snorkel in inventory.

@export var requires_snorkel: bool = true
@export var zone_size: Vector2 = Vector2(512, 64)
@export var zone_center: Vector2 = Vector2(256, 352)

var _players_inside: Array[Node] = []


func _ready() -> void:
	add_to_group("water_zone")
	_apply_zone_bounds()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _apply_zone_bounds() -> void:
	var collision: CollisionShape2D = $CollisionShape2D
	var shape := collision.shape as RectangleShape2D
	if shape:
		shape.size = zone_size
	collision.position = zone_center
	if has_node("Visual"):
		var visual: ColorRect = $Visual
		visual.offset_left = zone_center.x - zone_size.x * 0.5
		visual.offset_top = zone_center.y - zone_size.y * 0.5
		visual.offset_right = zone_center.x + zone_size.x * 0.5
		visual.offset_bottom = zone_center.y + zone_size.y * 0.5


func _physics_process(_delta: float) -> void:
	for body in _players_inside.duplicate():
		if is_instance_valid(body):
			_check_player(body)
		else:
			_players_inside.erase(body)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body not in _players_inside:
		_players_inside.append(body)
		_check_player(body)


func _on_body_exited(body: Node2D) -> void:
	_players_inside.erase(body)


func _check_player(body: Node) -> void:
	if not is_instance_valid(body) or not body.is_inside_tree():
		return
	if not requires_snorkel or Inventory.has_item("snorkel"):
		return
	if body.has_method("die_from_hazard"):
		body.call("die_from_hazard")
