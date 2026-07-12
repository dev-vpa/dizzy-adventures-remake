extends Node

## Root flow: menu → game select → loading → gameplay.

enum State { MAIN_MENU, GAME_SELECT, LOADING, PLAYING }

const MAIN_MENU_SCENE := preload("res://scenes/main_menu.tscn")
const GAME_SELECT_SCENE := preload("res://scenes/game_select.tscn")
const LOADING_SCENE := preload("res://scenes/loading_screen.tscn")
const GAME_WORLD_SCENE := preload("res://scenes/game_world.tscn")

const GAME_REGISTRY: Array[GameConfig] = [
	preload("res://games/treasure-island/treasure_island_config.tres"),
]

var state: State = State.MAIN_MENU
var active_config: GameConfig


func _ready() -> void:
	_show_main_menu()


func _change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)


func _show_main_menu() -> void:
	state = State.MAIN_MENU
	active_config = null
	_change_scene(MAIN_MENU_SCENE)


func show_game_select() -> void:
	state = State.GAME_SELECT
	_change_scene(GAME_SELECT_SCENE)


func start_game(config: GameConfig) -> void:
	if config == null or not config.enabled:
		push_warning("GameManager: invalid or disabled game config.")
		return
	active_config = config
	state = State.LOADING
	Inventory.configure(config.inventory_slots)
	Lives.configure(config.starting_lives)
	_change_scene(LOADING_SCENE)


func enter_gameplay() -> void:
	if active_config == null:
		push_error("GameManager: no active game config.")
		_show_main_menu()
		return
	state = State.PLAYING
	ScreenManager.configure(active_config)
	_change_scene(GAME_WORLD_SCENE)


func quit_to_main_menu() -> void:
	ScreenManager.reset()
	Inventory.clear()
	Lives.reset()
	_show_main_menu()


func get_available_games() -> Array[GameConfig]:
	var result: Array[GameConfig] = []
	for config in GAME_REGISTRY:
		if config.enabled:
			result.append(config)
	return result
