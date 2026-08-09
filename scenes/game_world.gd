extends Node2D

## Active gameplay shell: loads flick-screens and hosts the player.

const PLAYER_SCENE := preload("res://core/player/player.tscn")

## F5 playtest only: screen id, or "" to use config (beach_start).
## Full playthrough test: keep "beach_start" (or "").
const DEBUG_START_SCREEN := "beach_start"
## Extra items on top of per-screen seeds below. Example: ["snorkel", "golden_key"]
const DEBUG_GIVE_ITEMS: Array[String] = []

@onready var screen_container: Node2D = $ScreenContainer
@onready var player: CharacterBody2D = $Player

var _transition_cooldown := 0.0


func _ready() -> void:
	add_to_group("game_world")
	var start_id := _resolve_start_screen_id()
	ScreenManager.load_screen(start_id, screen_container, player)
	_apply_debug_start_items(start_id)
	if OS.is_debug_build() and start_id != ScreenManager.get_start_screen_id():
		print("Debug start screen: %s" % start_id)


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_reload_screen"):
		_debug_reload_current_screen()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _transition_cooldown > 0.0:
		_transition_cooldown -= delta


func request_edge_transition(body: CharacterBody2D) -> void:
	if ScreenManager.try_directional_transition(body, screen_container):
		_transition_cooldown = 0.6
		return
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
	# Door use is deliberate — do not block on the horizontal edge cooldown.
	ScreenManager.transition_to(target_id, spawn_position, screen_container, body, block_edge)
	_transition_cooldown = 0.35


func _resolve_start_screen_id() -> String:
	var configured := ScreenManager.get_start_screen_id()
	if not OS.is_debug_build():
		return configured
	if not DEBUG_START_SCREEN.is_empty():
		return DEBUG_START_SCREEN
	for arg in OS.get_cmdline_user_args():
		var value := ""
		if arg.begins_with("--screen="):
			value = arg.trim_prefix("--screen=")
		elif arg.begins_with("screen="):
			value = arg.trim_prefix("screen=")
		if not value.is_empty():
			return value
	return configured


func _apply_debug_start_items(start_id: String) -> void:
	if not OS.is_debug_build():
		return
	for item_id in DEBUG_GIVE_ITEMS:
		Inventory.try_pick_up(item_id)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--give="):
			Inventory.try_pick_up(arg.trim_prefix("--give="))
		elif arg.begins_with("give="):
			Inventory.try_pick_up(arg.trim_prefix("give="))
	# Playtest seeds when jumping straight to a puzzle screen.
	match start_id:
		"bridge_approach":
			Inventory.try_pick_up("woodcutters_axe")
		"bridge_cavern_treasure":
			Inventory.try_pick_up("holy_bible")
		"grave_hill":
			Inventory.try_pick_up("glass_sword")
		"mine_blast":
			Inventory.try_pick_up("dynamite")
			Inventory.try_pick_up("detonator")
		"ocean_bubble_cave":
			Inventory.try_pick_up("snorkel")
			Inventory.try_pick_up("salt_spade")
		"ocean_entry", "ocean_fish_run", "ocean_wreck", "ocean_spade_bay":
			Inventory.try_pick_up("snorkel")
		"cavern_kitchen_door", "blackbeard_kitchen":
			Inventory.try_pick_up("golden_key")
			WorldState.set_flag("kitchen_open")
		"pier_boat":
			Inventory.try_pick_up("dehydrated_boat")
		"taxman_dock":
			WorldState.set_flag("boat_ready")
			Collectibles.set_collected(Collectibles.total)


func _debug_reload_current_screen() -> void:
	var screen_id := ScreenManager.current_screen_id
	if screen_id.is_empty():
		return
	if not ScreenManager.reload_screen_resource(screen_id):
		return
	ScreenManager.transition_to(screen_id, Vector2(256.0, 350.0), screen_container, player)
	print("Debug reload screen (from disk): %s" % screen_id)
