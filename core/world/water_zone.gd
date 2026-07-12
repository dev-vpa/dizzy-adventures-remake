extends Area2D

## Water hazard — drowns player without snorkel in inventory.

@export var requires_snorkel: bool = true

var _players_inside: Array[Node] = []


func _ready() -> void:
	add_to_group("water_zone")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	for body in _players_inside:
		_check_player(body)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body not in _players_inside:
		_players_inside.append(body)
		_check_player(body)


func _on_body_exited(body: Node2D) -> void:
	_players_inside.erase(body)


func _check_player(body: Node) -> void:
	if not requires_snorkel or Inventory.has_item("snorkel"):
		return
	if body.has_method("die_from_hazard"):
		body.call("die_from_hazard")
