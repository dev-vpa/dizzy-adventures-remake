extends Node2D

## Active gameplay shell: loads flick-screens and hosts the player.

const PLAYER_SCENE := preload("res://core/player/player.tscn")

@onready var screen_container: Node2D = $ScreenContainer
@onready var player: CharacterBody2D = $Player

var _transition_cooldown := 0.0


func _ready() -> void:
	add_to_group("game_world")
	var start_id := ScreenManager.get_start_screen_id()
	ScreenManager.load_screen(start_id, screen_container, player)


func _process(delta: float) -> void:
	if _transition_cooldown > 0.0:
		_transition_cooldown -= delta


func request_edge_transition(body: CharacterBody2D) -> void:
	if _transition_cooldown > 0.0:
		return
	ScreenManager.try_edge_transition(body, screen_container)
	_transition_cooldown = 0.6


func request_door_transition(
	body: CharacterBody2D,
	target_id: String,
	spawn_position: Vector2,
	block_edge: String = ""
) -> void:
	if _transition_cooldown > 0.0:
		return
	ScreenManager.transition_to(target_id, spawn_position, screen_container, body, block_edge)
	_transition_cooldown = 0.6
