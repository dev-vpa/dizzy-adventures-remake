extends CharacterBody2D

## Dizzy player: platform movement, somersault jump, item pickup.

const GRAVITY := 980.0
const MOVE_SPEED := 140.0
const JUMP_VELOCITY := -320.0
const SOMERSAULT_SPEED := 12.0

@onready var sprite: ColorRect = $Sprite
@onready var pickup_area: Area2D = $PickupArea

var _somersault_rotation: float = 0.0
var _picked_items: Dictionary = {}


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		_somersault_rotation = 0.0
		sprite.rotation = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_somersault_rotation = SOMERSAULT_SPEED

	if not is_on_floor() and _somersault_rotation != 0.0:
		sprite.rotation += _somersault_rotation * delta

	move_and_slide()
	_try_pickup_nearby()
	_check_screen_edge()


func _try_pickup_nearby() -> void:
	if not Input.is_action_just_pressed("action"):
		return

	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("pickup") and area.has_method("try_pick_up"):
			if area.call("try_pick_up"):
				return


func _check_screen_edge() -> void:
	var world := get_tree().get_first_node_in_group("game_world")
	if world and world.has_method("request_edge_transition"):
		world.call("request_edge_transition", self)


func on_screen_entered(_screen_id: String) -> void:
	pass
