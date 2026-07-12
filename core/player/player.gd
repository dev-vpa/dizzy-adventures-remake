extends CharacterBody2D

## Dizzy player: platform movement, somersault jump, item pickup/drop.

const GRAVITY := 980.0
const MOVE_SPEED := 140.0
const JUMP_VELOCITY := -320.0
const SOMERSAULT_SPEED := 12.0
const FALL_DEATH_Y := 392.0

const PICKUP_SCENE := preload("res://core/items/pickup_item.tscn")

@onready var sprite: DizzySprite = $DizzySprite
@onready var pickup_area: Area2D = $PickupArea
@onready var _screen_container: Node2D = get_parent().get_node("ScreenContainer")

var _somersault_rotation: float = 0.0
var _facing: int = 1
var _spawn_position: Vector2
var _action_queued := false
var _hazard_cooldown := 0.0
var _blocked_edges: Dictionary = {}


func _ready() -> void:
	add_to_group("player")
	_spawn_position = global_position


func request_action() -> void:
	_action_queued = true


func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		_somersault_rotation = 0.0
		sprite.rotation = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	if direction != 0:
		_facing = 1 if direction > 0 else -1
		sprite.set_facing(_facing)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_somersault_rotation = SOMERSAULT_SPEED

	if not is_on_floor() and _somersault_rotation != 0.0:
		sprite.rotation += _somersault_rotation * delta

	move_and_slide()
	ScreenManager.clamp_player_to_bounds(self, _screen_container)
	if _hazard_cooldown > 0.0:
		_hazard_cooldown -= delta
	_tick_edge_blocks(delta)
	_handle_inventory_input()
	_try_action_nearby()
	_check_fall_death()
	_check_screen_edge()


func _handle_inventory_input() -> void:
	if Input.is_action_just_pressed("inventory_next"):
		Inventory.select_next()
	if Input.is_action_just_pressed("drop"):
		_try_drop_item()
	if Input.is_action_just_pressed("use_item"):
		Inventory.try_use_selected()


func _try_action_nearby() -> void:
	var wants_action := _action_queued or Input.is_action_just_pressed("action")
	if not wants_action:
		return
	_action_queued = false

	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("pickup") and area.has_method("try_pick_up"):
			if area.call("try_pick_up"):
				return

	for node in get_tree().get_nodes_in_group("interactable"):
		if node is Area2D and (node as Area2D).overlaps_body(self):
			if node.has_method("try_interact") and node.call("try_interact"):
				return

	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("interactable") and area.has_method("try_interact"):
			if area.call("try_interact"):
				return


func drop_item() -> void:
	_try_drop_item()


func use_item() -> void:
	Inventory.try_use_selected()


func _try_drop_item() -> void:
	var item_id := Inventory.try_drop_selected()
	if item_id.is_empty():
		return

	if _screen_container.get_child_count() == 0:
		return

	var screen := _screen_container.get_child(0) as Node2D
	var pickup: Area2D = PICKUP_SCENE.instantiate()
	pickup.item_id = item_id
	pickup.display_name = ItemCatalog.get_display_name(item_id)
	screen.add_child(pickup)
	pickup.global_position = global_position + Vector2(float(_facing) * 12.0, -8.0)


func _check_fall_death() -> void:
	if _hazard_cooldown > 0.0:
		return
	if global_position.y >= FALL_DEATH_Y:
		_handle_death()


func die_from_hazard() -> void:
	if _hazard_cooldown > 0.0:
		return
	_hazard_cooldown = 0.6
	_handle_death()


func _handle_death() -> void:
	if not is_inside_tree():
		return
	var game_over := Lives.lose_life()
	if game_over:
		GameManager.quit_to_main_menu()
		return

	global_position = _spawn_position
	velocity = Vector2.ZERO


func _check_screen_edge() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	var world := tree.get_first_node_in_group("game_world")
	if world and world.has_method("request_edge_transition"):
		world.call("request_edge_transition", self)


func on_screen_entered(_screen_id: String) -> void:
	velocity = Vector2.ZERO
	_spawn_position = global_position
	_hazard_cooldown = 1.0
	_blocked_edges.erase("up")
	_blocked_edges.erase("down")


func is_edge_blocked(edge: String) -> bool:
	return _blocked_edges.get(edge, 0.0) > 0.0


func block_edge(edge: String, duration: float) -> void:
	if duration <= 0.0:
		return
	_blocked_edges[edge] = maxf(_blocked_edges.get(edge, 0.0), duration)


func _tick_edge_blocks(delta: float) -> void:
	if _blocked_edges.is_empty():
		return
	var expired: Array[String] = []
	for edge in _blocked_edges:
		_blocked_edges[edge] -= delta
		if _blocked_edges[edge] <= 0.0:
			expired.append(edge)
	for edge in expired:
		_blocked_edges.erase(edge)
