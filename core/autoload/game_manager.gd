extends Node

## Root flow: menu → game select → loading → title → gameplay.

enum State { MAIN_MENU, GAME_SELECT, LOADING, TITLE, PLAYING }

const MAIN_MENU_SCENE := preload("res://scenes/main_menu.tscn")
const GAME_SELECT_SCENE := preload("res://scenes/game_select.tscn")
const LOADING_SCENE := preload("res://scenes/loading_screen.tscn")
const TITLE_SCENE := preload("res://games/treasure-island/title_screen.tscn")
const GAME_WORLD_SCENE := preload("res://scenes/game_world.tscn")
const WIN_SCENE := preload("res://scenes/win_screen.tscn")

const GAME_REGISTRY: Array[GameConfig] = [
	preload("res://games/treasure-island/treasure_island_config.tres"),
]

var state: State = State.MAIN_MENU
var active_config: GameConfig


func _ready() -> void:
	# Normal player flow: main menu → select → disclaimer → title → gameplay.
	# Opt-in debug shortcut only: --skip-menu
	if OS.is_debug_build() and _debug_wants_skip_menu():
		_debug_boot_into_gameplay()
	else:
		_show_main_menu()


func _debug_wants_skip_menu() -> bool:
	if DisplayServer.get_name() == "headless":
		return false
	for arg in OS.get_cmdline_user_args():
		if arg == "--skip-menu" or arg == "skip-menu":
			return true
	return false


func _debug_boot_into_gameplay() -> void:
	var games := get_available_games()
	if games.is_empty():
		_show_main_menu()
		return
	var config: GameConfig = games[0]
	active_config = config
	state = State.PLAYING
	Inventory.configure(config.inventory_slots)
	Lives.configure(config.starting_lives)
	Collectibles.configure(config.collectible_name, config.collectible_total)
	WorldState.reset()
	SaveGame.clear_runtime()
	ScreenManager.configure(config)
	print("Debug: --skip-menu → %s (start: %s)" % [config.id, config.starting_screen_id])
	AudioManager.play_music()
	_change_scene(GAME_WORLD_SCENE)


func _change_scene(scene: PackedScene) -> void:
	var tree := get_tree()
	if tree == null:
		return
	tree.call_deferred("change_scene_to_packed", scene)


func _show_main_menu() -> void:
	state = State.MAIN_MENU
	active_config = null
	AudioManager.stop_music()
	_change_scene(MAIN_MENU_SCENE)


func show_game_select() -> void:
	state = State.GAME_SELECT
	AudioManager.stop_music()
	_change_scene(GAME_SELECT_SCENE)


func start_game(config: GameConfig) -> void:
	if config == null or not config.enabled:
		push_warning("GameManager: invalid or disabled game config.")
		return
	active_config = config
	state = State.LOADING
	_change_scene(LOADING_SCENE)


func show_title_screen() -> void:
	if active_config == null:
		_show_main_menu()
		return
	state = State.TITLE
	_change_scene(TITLE_SCENE)


func begin_new_game() -> void:
	if active_config == null:
		_show_main_menu()
		return
	Inventory.configure(active_config.inventory_slots)
	Lives.configure(active_config.starting_lives)
	Collectibles.configure(active_config.collectible_name, active_config.collectible_total)
	WorldState.reset()
	SaveGame.begin_new_game(active_config.id)
	enter_gameplay()


func begin_continue_game() -> void:
	if active_config == null:
		_show_main_menu()
		return
	Inventory.configure(active_config.inventory_slots)
	Lives.configure(active_config.starting_lives)
	Collectibles.configure(active_config.collectible_name, active_config.collectible_total)
	WorldState.reset()
	if not SaveGame.begin_continue(active_config.id):
		begin_new_game()
		return
	enter_gameplay()


func enter_gameplay() -> void:
	if active_config == null:
		push_error("GameManager: no active game config.")
		_show_main_menu()
		return
	state = State.PLAYING
	ScreenManager.configure(active_config)
	AudioManager.play_music()
	_change_scene(GAME_WORLD_SCENE)


func quit_to_main_menu() -> void:
	if state == State.PLAYING and active_config:
		SaveGame.request_save(active_config.id)
	ScreenManager.reset()
	Inventory.clear()
	Lives.reset()
	Collectibles.reset()
	WorldState.reset()
	SaveGame.clear_runtime()
	_show_main_menu()


func declare_win() -> void:
	state = State.MAIN_MENU
	if active_config:
		SaveGame.delete_save(active_config.id)
	AudioManager.stop_music()
	AudioManager.play_sfx("win")
	ScreenManager.reset()
	Inventory.clear()
	Lives.reset()
	_change_scene(WIN_SCENE)


func get_available_games() -> Array[GameConfig]:
	var result: Array[GameConfig] = []
	for config in GAME_REGISTRY:
		if config.enabled:
			result.append(config)
	return result
