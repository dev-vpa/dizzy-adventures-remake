extends Node

## Window setup for standalone runs. Skips resize when embedded in Godot editor.


func _ready() -> void:
	await get_tree().process_frame
	_setup_window()


func _setup_window() -> void:
	var root: Window = get_tree().root
	if root.is_embedded():
		return

	var screen_index := root.current_screen
	var usable := DisplayServer.screen_get_usable_rect(screen_index)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(usable.size)
	DisplayServer.window_set_position(usable.position)
